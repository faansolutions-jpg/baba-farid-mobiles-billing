# API Reference — Baba Farid Mobiles Backend (Module 4)

Base URL: `http://localhost:3000/api/v1` (port from `PORT` in `.env`).
Health check: `GET /health` (no auth) → `{ ok: true, data: { status: "up", time } }`.

## Envelope

Every response uses the same shape:

```json
// Success
{ "ok": true, "data": { ... }, "meta": { "page": 1, "limit": 20, "total": 42, "totalPages": 3 } }
// Error
{ "ok": false, "error": { "message": "...", "code": "BAD_REQUEST", "details": { ... } } }
```

`meta` is present only on paginated list endpoints. `details` carries Zod field
errors on validation failures.

## Auth

`Authorization: Bearer <access_token>` on every endpoint except `POST /login`,
`POST /refresh` and `GET /health`. Access tokens live 15 minutes; refresh
tokens 7 days (see `.env`: `JWT_ACCESS_EXPIRES_IN`, `JWT_REFRESH_EXPIRES_IN`).

Roles: `owner`, `manager`, `cashier` (the schema names the admin role `owner`,
not `admin`). **Cashiers never receive cost fields** (`purchase_price`,
`purchase_cost`, `min_price`, `profit`, `cost`) — the server strips them from
every product / variant / sale / IMEI payload (`utils/sanitize.ts`).

| Code | Meaning |
| ---- | ------- |
| 400 `BAD_REQUEST` | Validation failed, or a business rule was broken (message says which) |
| 401 `UNAUTHORIZED` | Missing / invalid / expired token |
| 403 `FORBIDDEN` | Role not allowed, or min-price approval missing (`MIN_PRICE_APPROVAL_REQUIRED`) |
| 404 `NOT_FOUND` | Record not found |
| 409 `CONFLICT` | Duplicate (IMEI, phone, barcode) or insufficient stock / already returned |
| 429 `RATE_LIMITED` | Too many login attempts (5 per 15 min per IP) |
| 500 `INTERNAL` | Unexpected server error |

All money is **whole PKR integers** (`NUMERIC(12,0)`). No paisa anywhere.
Pagination: `?page=1&limit=20` (limit capped at 100).

---

## 1. Auth — `/api/v1`

| Method | Path | Role | Body | Response | Notes |
| ------ | ---- | ---- | ---- | -------- | ----- |
| POST | `/login` | — | `{ phone, password }` | `{ user, accessToken, refreshToken }` | Rate-limited: 5/15 min/IP. Updates `last_login_at`, writes an audit `login` row. |
| POST | `/refresh` | — | `{ refreshToken }` | `{ accessToken, refreshToken }` | Stateless refresh (JWT). A new refresh token is issued each time. |
| POST | `/logout` | any | — | `{ message }` | Stateless: the client discards both tokens. There is no server-side token list (the schema has no refresh-token table). |
| GET | `/me` | any | — | Current user (no `password_hash`) | |
| POST | `/change-password` | any | `{ currentPassword, newPassword }` | `{ message }` | bcrypt cost 12. |
| GET | `/users` | owner | `?page&limit` | Paginated users | |
| POST | `/users` | owner | `{ name, phone, email?, password, roleId, branchId? }` | Created user | |
| GET | `/users/:id` | owner | — | One user | |
| PATCH | `/users/:id` | owner | `{ name?, phone?, email?, roleId?, branchId?, isActive? }` | Updated user | |
| DELETE | `/users/:id` | owner | — | `{ message }` | Soft-deactivates (`is_active = false`); the row is never deleted. |

---

## 2. Products — `/api/v1`

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| GET | `/products` | any | `?search&type&brandId&categoryId&isActive&page&limit` | Paginated products (each with its variants) | Cashiers get no cost fields. |
| GET | `/products/low-stock` | any | — | Variants at/below `low_stock_threshold` (+ phones: available IMEI count) | |
| GET | `/products/export` | owner/manager | — | CSV download (`products-export.csv`) | Cashiers get no cost columns. |
| POST | `/products/import` | owner/manager | `{ csv: "<csv text>" }` | `{ created, updated, skipped, errors[] }` | Bulk import; one row per product+variant. See CSV format below. |
| GET | `/products/:id` | any | — | Product + variants | |
| POST | `/products` | owner/manager | `{ brandId?, categoryId?, type: "phone"\|"accessory", name, description?, barcode?, imageUrl? }` | Created product | |
| PATCH | `/products/:id` | owner/manager | Same fields, all optional | Updated product | |
| DELETE | `/products/:id` | owner/manager | — | `{ message }` | Soft-deactivates. |
| POST | `/products/:id/variants` | owner/manager | `{ name, color?, storageGb?, ramGb?, condition?, ptaStatus?, barcode?, purchasePrice, salePrice, minPrice?, warrantyMonths?, quantity?, lowStockThreshold? }` | Created variant | `quantity` is accessory stock. Phones use IMEI rows instead. |
| PATCH | `/variants/:id` | owner/manager | Same fields, all optional | Updated variant | |
| DELETE | `/variants/:id` | owner/manager | — | `{ message }` | Soft-deactivates. |
| GET | `/imei` | any | `?status&productId&search&page&limit` | Paginated IMEI items | Cashiers get no cost fields. |
| GET | `/imei/:imei` | any | — | One IMEI item (by IMEI-1 or IMEI-2) | |
| POST | `/imei` | owner/manager | `{ productId, variantId, imei1, imei2?, purchasePrice, salePrice }` | Created IMEI item (`available`) | Duplicate IMEI → 409 (unique constraint). |
| PATCH | `/imei/:id/status` | owner/manager | `{ status: "available"\|"sold"\|"reserved"\|"returned"\|"defective" }` | Updated IMEI item | Manual override (e.g. mark defective). |
| GET | `/brands` | any | — | All brands | |
| POST | `/brands` | owner/manager | `{ name }` | Created brand | |
| GET | `/categories` | any | — | All categories | |
| POST | `/categories` | owner/manager | `{ name, type: "phone"\|"accessory"\|"service", parentId? }` | Created category | |

**Import CSV columns** (header row required):
`name, type, brand, category, variant_name, color, storage_gb, ram_gb, purchase_price, sale_price, min_price, quantity, barcode`.
Brands/categories are created on the fly when missing. Rows with errors are
reported in `errors[]` and skipped; valid rows are still imported.

---

## 3. Sales (POS) — `/api/v1`

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| POST | `/sales` | any | See **Create bill** below | Created bill (with items, payments, returns) | **One DB transaction**: sale + items + IMEI status + stock deduction + payment + ledger + audit. All-or-nothing. |
| GET | `/sales` | any | `?from&to&customerId&status&paymentStatus&branchId&search&page&limit` | Paginated bills | `status`: completed / returned / partially_returned / cancelled / held. |
| GET | `/sales/:id` | any | — | One bill with items, payments, returns | |
| GET | `/sales/:id/invoice` | any | — | `{ shop, sale }` (shop profile from settings + the bill) | For thermal printing / PDF / WhatsApp share. |
| POST | `/sales/:id/return` | owner/manager | `{ items: [{ saleItemId, quantity, reason? }], exchangeSaleId? }` | Updated bill | Restocks (IMEI → available, accessory qty back), refunds, ledger credit. See **Returns** below. |
| POST | `/sales/:id/cancel` | **owner only** | — | Updated bill (status `cancelled`) | Reverses everything like a full return, refunds collected cash via the open register, credits the customer's balance. |
| POST | `/sales/:id/payments` | any | `{ amount, method?, reference?, notes? }` | Updated bill | Udhaar recovery against the remaining balance. |
| POST | `/sales/hold` | any | `{ customerName?, cart: [ ... ] }` | Held bill | Parks a bill mid-sale; `cart` is stored as JSONB. |
| GET | `/sales/hold` | any | — | Held bills for the user's branch | |
| POST | `/sales/hold/:id/resume` | any | — | The held bill (and deletes it from the hold list) | |
| DELETE | `/sales/hold/:id` | any | — | `{ message }` | Discards a held bill. |

### Create bill — request body

```json
{
  "customerId": "uuid | null",
  "customerName": "Walk-in name (when no customerId)",
  "customerPhone": "03xx-xxxxxxx",
  "items": [
    { "variantId": "uuid", "imeiItemId": "uuid (phones only)", "quantity": 1,
      "unitPrice": 45000, "discount": 0 }
  ],
  "discountAmount": 0,
  "discountPercent": 0,
  "taxAmount": 0,
  "paymentMethod": "cash | jazzcash | easypaisa | bank_transfer | card | partial | udhaar",
  "paidAmount": 45000,
  "adminApprovedBy": "uuid (owner/manager id — only when a price is below min_price)",
  "notes": "...",
  "clientUuid": "uuid (offline-sync idempotency key)"
}
```

### Payment rules (enforced in the transaction)

- `cash` / `jazzcash` / `easypaisa` / `bank_transfer` / `card` → `paidAmount`
  must equal the grand total.
- `partial` → `0 < paidAmount < grandTotal`.
- `udhaar` → `paidAmount` must be `0` (the whole bill goes on the customer's ledger).
- `paidAmount` can never exceed the grand total.
- A bill-level flat discount wins over a percent discount; the discount can
  never exceed the subtotal; the grand total can never go below 0.
- **Below-minimum-price**: if `unitPrice < variant.min_price` the bill is
  rejected with 403 `MIN_PRICE_APPROVAL_REQUIRED` unless `adminApprovedBy`
  is an owner/manager user id.
- **Sold IMEI**: a phone is sold only when its IMEI item is `available`
  (checked + locked inside the transaction). A sold IMEI can never be sold
  again unless it is returned first (return sets it back to `available`).
- **Profit** is stored per line: `profit = (unitPrice × qty − line discount) − purchase_cost × qty`.
  For phones the purchase cost comes from the IMEI item; for accessories from
  the variant.

### Returns

Refund = pro-rata share of the line total. The refund is split: first from
what was paid (cash out of today's open register, best-effort), then from
the remaining balance (a credit on the customer's ledger). If every item is
returned the bill becomes `returned`, otherwise `partially_returned`.
`exchangeSaleId` links the return to the replacement bill (the new bill is
created with a normal `POST /sales`).

**Effect on the bill (Round 3 fix):** a return reduces the bill's
`grand_total` by the refund (and `paid` by the refund taken from paid
money), and reduces each returned line's `sale_items.profit` pro-rata, so a
returned bill stops counting as revenue/profit in the dashboard and
profit-loss report. The customer ledger is credited only with the part of
the refund that came from the unpaid balance (`refund − min(refund, paid)`),
never with money already handed back in cash — a fully returned partial
bill ends at balance 0, not negative. Returning more than the un-returned
quantity of a line is rejected (400).

---

## 4. Purchases & Suppliers — `/api/v1`

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| POST | `/purchases` | owner/manager | See **Create purchase** below | Created purchase (with items + payments) | **One transaction**: purchase + items + IMEI rows (available) / accessory qty + supplier ledger + payment + audit. |
| GET | `/purchases` | owner/manager | `?supplierId&from&to&status&page&limit` | Paginated purchases | |
| GET | `/purchases/:id` | owner/manager | — | Purchase with items + payments | |
| POST | `/purchases/:id/return` | owner/manager | `{ items: [{ purchaseItemId, quantity, reason? }] }` | Updated purchase | Removes stock (IMEI → `returned`, accessory qty down), reduces the supplier payable. A sold IMEI cannot be returned to the supplier. |
| POST | `/purchases/:id/payments` | owner/manager | `{ amount, method?, reference?, notes? }` | Updated purchase | Pays the supplier against the remaining balance. |
| GET | `/suppliers` | owner/manager | `?search&page&limit` | Paginated suppliers (each with `payable_balance`) | `payable_balance` = SUM of all supplier ledger entries (`credit − debit`), falling back to `opening_payable` when the ledger is empty. Opening payables are ledger rows, so they are included in the sum. |
| POST | `/suppliers` | owner/manager | `{ name, phone?, address?, openingPayable? }` | Created supplier | |
| GET | `/suppliers/:id` | owner/manager | — | Supplier + `payable_balance` | |
| PATCH | `/suppliers/:id` | owner/manager | `{ name?, phone?, address?, isActive? }` | Updated supplier | |
| GET | `/suppliers/:id/ledger` | owner/manager | `?page&limit` | Ledger entries + `meta.payableBalance` | Running-balance statement; the balance is the SUM of entries, not the latest row. |

### Create purchase — request body

```json
{
  "supplierId": "uuid",
  "supplierInvoiceNo": "SUP-123",
  "items": [
    { "productId": "uuid", "variantId": "uuid",
      "imei1": "860123456789012", "imei2": "860123456789013",
      "quantity": 1, "unitCost": 42000 }
  ],
  "discount": 0,
  "paidAmount": 0,
  "paymentMethod": "cash",
  "notes": "...",
  "clientUuid": "uuid (idempotency key)"
}
```

Phones need `imei1` and `quantity: 1` per line (one row per IMEI); accessories
use `quantity` and no IMEI. Duplicate IMEI → 409. The supplier ledger is
credited with the grand total and debited with the amount paid, so the
payable is `grand_total − paid`.

---

## 5. Customers, Ledger & Installments — `/api/v1`

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| GET | `/customers` | any | `?search&page&limit` | Paginated customers (each with `balance`) | `balance` = SUM of all ledger entries (`debit − credit`), falling back to `opening_balance` when the ledger is empty. Opening balances are themselves ledger rows, so they are included in the sum. |
| POST | `/customers` | any | `{ name, phone, cnic?, address?, openingBalance? }` | Created customer | |
| GET | `/customers/:id` | any | — | Customer + `balance` | |
| PATCH | `/customers/:id` | any | `{ name?, phone?, cnic?, address?, isActive? }` | Updated customer | |
| DELETE | `/customers/:id` | any | — | `{ message }` | Soft-deactivates. |
| GET | `/customers/:id/ledger` | any | `?page&limit` | Ledger entries + `meta.balance` | Running-balance statement (opening entry is written on first use). |
| GET | `/customers/:id/installments` | any | — | Installment plans for the customer | |
| POST | `/installments` | any | `{ saleId, downPayment?, installmentCount: 1–36, startDate: "YYYY-MM-DD" }` | Plan with its schedule | Splits the bill's `balance_due` into monthly parts; the remainder from rounding goes on the last installment. `downPayment` must equal what was already collected on the bill (pass it only to be explicit). |
| GET | `/installments/overdue` | any | — | Overdue installment rows (with customer + bill) | Due date passed and not fully paid. The endpoint first flips past-due `pending`/`partial` installments to status `overdue`, then lists `overdue` rows — so an installment whose due date just passed shows up immediately. |
| GET | `/installments/:id` | any | — | Plan with its schedule | |
| POST | `/installments/:id/payments` | any | `{ installmentPaymentId, amount, method?, reference?, notes? }` | Updated plan | Full or partial payment of one installment; updates the bill, the ledger, and completes the plan when every row is paid. |

---

## 6. Repairs & Service Sales — `/api/v1`

Repair statuses (schema enum `repair_status`): `received → in_progress →
ready → delivered`, plus `cancelled`. Status can only move forward (back to
`received` is allowed for rework). Delivery is a separate endpoint because it
finalises billing.

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| POST | `/repairs` | any | See **Create repair** below | Created job (with `parts: []`, `balance_due`) | Job number from the `repair_job` counter (`REP-000123`). |
| GET | `/repairs` | any | `?status&customerId&search&page&limit` | Paginated jobs (each with computed `balance_due`) | |
| GET | `/repairs/:id` | any | — | Job with parts | |
| PATCH | `/repairs/:id` | any | `{ deviceBrand?, deviceModel?, imei?, faultDescription?, estimatedCost?, notes?, status?: "received"\|"in_progress"\|"ready"\|"cancelled" }` | Updated job | Setting `ready` stamps `ready_date`. `delivered` is rejected here — use the deliver endpoint. |
| POST | `/repairs/:id/cancel` | owner/manager | — | Cancelled job | Fitted parts go back to stock. |
| POST | `/repairs/:id/parts` | any | `{ productId, variantId, quantity?, unitPrice }` | Updated job | Validates stock, deducts it, adds the part cost to `final_cost`. |
| POST | `/repairs/:id/deliver` | any | `{ parts?: [...], finalCost?, paymentMethod?, notes? }` | Delivered job | Fits any extra parts, sets the final bill, collects the remaining amount, writes the ledger charge + payment, stamps `delivered_date`. |
| GET | `/service-sales` | any | `?serviceType&from&to&page&limit` | Paginated service sales | easyload / recharge / bill payment. |
| POST | `/service-sales` | any | `{ serviceType: "easyload"\|"recharge"\|"bill_payment"\|"other", customerPhone?, provider?, amount, commission? }` | Created service sale | `commission` is the shop's earning on the transaction. |

### Create repair — request body

```json
{
  "customerId": "uuid (registered customer)",
  "customerName": "Walk-in name (when no customerId)",
  "customerPhone": "03xx-xxxxxxx (when no customerId)",
  "deviceBrand": "Samsung",
  "deviceModel": "Galaxy A15",
  "imei": "860123456789012",
  "faultDescription": "Screen cracked, touch not working",
  "estimatedCost": 5000,
  "advancePaid": 2000,
  "notes": "..."
}
```

Either `customerId` or (`customerName` + `customerPhone`) is required. The
advance is recorded as a `repair` payment and credited on the customer's
ledger (registered customers only). At delivery, the ledger gets the charge
(`debit = final_cost`) and the pickup payment (`credit = remaining`), so the
job nets to zero. `balance_due` on a job is computed as
`max(0, final_cost − advance_paid)` — there is no `balance_due` column in the
schema.

**Known schema gap:** the spec asks for an "assigned technician", but the
schema's `repairs` table has no technician column (only `user_id`, the user
who created the job). Technician assignment needs a schema addition; it is
not in this module.

---

## 7. Expenses, Staff, Salaries & Cash Register — `/api/v1`

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| GET | `/expenses/categories` | any | — | `[ "rent", "electricity", ... ]` | Standard list + any category already used. The schema stores `category` as plain TEXT — there is no category table. |
| GET | `/expenses` | any | `?category&from&to&page&limit` | Paginated expenses | |
| POST | `/expenses` | any | `{ category, amount, description? }` | Created expense | Expenses are paid in cash from the drawer (no payment-method column in the schema), so every expense reduces the day's expected cash. |
| GET | `/expenses/:id` | any | — | One expense | |
| PATCH | `/expenses/:id` | any | `{ category?, amount?, description? }` | Updated expense | |
| DELETE | `/expenses/:id` | owner | — | `{ message }` | Hard delete (with audit row). |
| GET | `/staff` | owner/manager | `?page&limit` | Paginated staff | |
| POST | `/staff` | owner/manager | `{ name, phone?, role, salary?, isActive? }` | Created staff member | |
| PATCH | `/staff/:id` | owner/manager | `{ name?, phone?, role?, salary?, isActive? }` | Updated staff member | |
| GET | `/salaries` | owner/manager | `?month=YYYY-MM&page&limit` | Paginated salary payments (each with `net_paid`) | |
| POST | `/salaries` | owner | `{ staffId, month: "YYYY-MM", amount, advance?, notes? }` | Created salary payment | One row per staff per month (duplicate → 409). `net_paid = amount − advance`. Stored in `salary_payments`. |
| GET | `/cash-register/today` | any | — | Today's register (or `null`) | |
| POST | `/cash-register/open` | any | `{ openingCash, notes? }` | Opened register | One open register per branch per day (duplicate → 409). |
| POST | `/cash-register/movements` | any | `{ type: "in"\|"out", amount, reason }` | Created movement | Needs an open register today. |
| POST | `/cash-register/close` | owner/manager | `{ closingCash, notes? }` | Closed register + `summary` | Computes expected cash and the difference (counted − expected). |
| GET | `/cash-register/day-summary` | any | — | Day summary (see below) | No register needed. |

### Day summary / expected cash

```
expectedCash = openingCash
             + cash received today (sale + installment + repair payments, method cash)
             + cash movements in
             − cash paid to suppliers today
             − cash expenses today
             − cash movements out
```

The cash received is read from the `payments` table (branch-resolved through
the linked sale / purchase, or through the user who recorded a repair
payment). `closing_cash` is what was actually counted; `difference` is
`closing − expected` (negative = short).

---

## 8. Reports — `/api/v1` (all GET, any authenticated role)

| Method | Path | Query | Response | Notes |
| ------ | ---- | ----- | -------- | ----- |
| GET | `/reports/dashboard` | `?branchId` | `{ today_sales, today_bills, month_sales, month_profit, total_udhaar, stock_value_cost, stock_value_sale, low_stock_count, out_of_stock_count, phones_in_stock, open_jobs, ready_pickup, overdue_count, overdue_amount }` | One call for the dashboard. Profit comes from `sale_items.profit` (sales has no profit column). Returned/cancelled sales contribute 0 revenue and 0 profit — a return reduces the bill's `grand_total` and line profit, so the dashboard never counts returned money. |
| GET | `/reports/sales` | `?branchId&from&to&groupBy=day\|week\|month` | `[{ period, bills, total_sales, total_profit, total_paid, total_udhaar }]` | |
| GET | `/reports/profit-loss` | `?branchId&from&to` | `{ from, to, revenue, grossProfit, discounts, bills, totalExpenses, totalSalaries, netProfit, netMarginPercent }` | `netProfit = grossProfit − expenses − salaries`. Salaries use `salary_payments.amount` by `paid_date` (no branch column). |
| GET | `/reports/stock-valuation` | — | `[{ product_id, product_name, brand, type, total_qty, value_at_cost, value_at_sale }]` | Accessories by quantity; phones are IMEI rows (see `phones_in_stock` on the dashboard). |
| GET | `/reports/brand-model-sales` | `?branchId&from&to` | `[{ brand, model, type, units_sold, revenue, profit }]` | Returns are netted out: `units_sold` = SUM of units sold minus units returned, `revenue`/`profit` net of refunds. |
| GET | `/reports/best-sellers` | `?branchId&from&to&limit=10` | `[{ product_name, brand, variant_name, units_sold, revenue, profit }]` | Returns are netted out the same way (units and revenue minus what was returned). |
| GET | `/reports/dead-stock` | `?days=90` | `[{ product_name, brand, variant_name, quantity, purchase_price, sale_price, tied_up_cost, last_sold }]` | Stock not sold in the last N days (or never sold). |
| GET | `/reports/pending-udhaar` | — | `[{ id, name, phone, balance, oldest_unpaid_bill }]` | Customers who owe money, largest balance first. |
| GET | `/reports/supplier-payables` | — | `[{ id, name, phone, balance, oldest_unpaid_purchase }]` | Suppliers we owe money to. |
| GET | `/reports/imei/:imei` | — | `{ found, imeiItem, purchase, sales[], returns[] }` | Full lifecycle of one IMEI. |

---

## 9. Settings — `/api/v1`

The `settings` table is key/value (`key TEXT PK, value JSONB`). Both endpoints
return a flat object of all keys (e.g. `{ "shop.name": "Baba Farid Mobiles",
"shop.address": "...", "shop.phone": "+92 329 9966771", "shop.phone2": "+92 302 4988560",
"shop.email": "baba.farid.mobiles.bfw@gmail.com", "shop.currency": "PKR",
"tax.enabled": false, "tax.rate": 0 }`).

| Method | Path | Role | Body | Response | Notes |
| ------ | ---- | ---- | ---- | -------- | ----- |
| GET | `/settings` | any | — | Flat settings object | |
| PATCH | `/settings` | owner | `{ shopName?, address?, phone?, phone2?, email?, whatsapp?, taxNumber?, logoUrl?, invoicePrefix?, invoiceFooter?, taxEnabled?, defaultTaxRate?, currency?, language?, timezone? }` | Updated flat settings object | Upserts the given keys only. |

---

## 10. Sync (offline-first) — `/api/v1`

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| POST | `/sync/push` | any | `{ deviceId, sales: [ ... ] }` | `{ accepted[], skipped[], errors[], serverTime }` | Pushes bills created offline. See below. |
| GET | `/sync/pull` | any | `?since=<ISO timestamp>&deviceId?` | `{ serverTime, products[], variants[], customers[], suppliers[], sales[], settings }` | Everything changed since `since`. Server wins on conflict. |
| GET | `/sync/history` | any | `?deviceId&limit=20` | Sync log rows (newest first) | From `sync_logs`. |

### Push — one sale

```json
{
  "clientUuid": "uuid (the phone's id for this bill — the idempotency key)",
  "customerId": "uuid | null",
  "customerName": "...", "customerPhone": "...",
  "items": [
    { "variantId": "uuid", "imei1": "860123456789012 (phones only)",
      "quantity": 1, "unitPrice": 45000, "discount": 0 }
  ],
  "discountAmount": 0, "discountPercent": 0, "taxAmount": 0,
  "paidAmount": 45000,
  "paymentMethod": "cash | jazzcash | easypaisa | bank_transfer | card | partial | udhaar",
  "notes": "...", "adminApprovedBy": "uuid | null"
}
```

Each sale is applied through the same `createSale` transaction as an online
bill, so all the same rules apply (IMEI availability, min-price approval,
payment rules, stock, ledger). A sale whose `clientUuid` already exists on
the server is reported in `skipped` (`already_synced`) and not created again
— a retry after a dropped connection is safe. A sale that fails validation
or a business rule is reported in `errors` with its `clientUuid` and the
message; the other sales in the same push are still applied. The phone
identifies a phone by its IMEI number; the server resolves it to the
`imei_items` row (unknown IMEI → that sale errors, it is not created).

### Client (Flutter) mapping — `mobile_app/lib/data/sync/sync_engine.dart`

The Flutter client adapts to this contract; it does NOT send the generic
`{ device_id, operations }` shape (the server rejects it with 400
`deviceId: Required` — verified live 2026-11-16).

- **Push:** the client reads its local `outbox` rows, converts each
  `sales`/`insert` row into the sale shape above, and posts
  `{ deviceId, sales }`. The sale's idempotency key is the
  `client_uuid` stored in the outbox payload (set when the bill was
  created), NOT the outbox row's own `clientUuid`. Phone lines resolve
  their local `imei_item_id` to the IMEI number via the local
  `imei_items` table; a line whose IMEI cannot be resolved is never
  sent — it is logged as a conflict and flagged on the local sale.
  `accepted` + `skipped` rows are marked synced; `errors` rows are
  logged via `_handleConflict` (marked synced so a permanently rejected
  sale is not retried forever; IMEI errors also flag the local sale's
  notes with `[SYNC CONFLICT: ...]`). A sale sent but missing from all
  three lists is left pending (outcome unknown; retry is safe by
  `clientUuid` idempotency).
- **Pull:** the client consumes the per-table arrays (`products`,
  `variants` → local `product_variants`, `customers`, `suppliers`,
  `sales`, `settings` as a flat object) through the same
  `_applyChange` logic as before: server-wins for master data
  (INSERT OR REPLACE), append-only for sales (INSERT OR IGNORE), and
  the IMEI safety rule — a locally-sold IMEI is never reverted to
  `available` by a pull.
- **Only sales push.** The server has no generic push endpoint, so
  non-sale outbox rows (products, customers, purchases, repairs,
  expenses, …) and non-`insert` sale rows (e.g. a cancel update) stay
  pending in the outbox and are NEVER marked synced. See
  `docs/sync.md` §3.1 for what syncs them instead.

---

## 11. Accessories Catalog — `/api/v1/catalog`

Mounted in `app.ts` (`api.use('/catalog', catalogRoutes)`). The catalog is
the pre-loaded Punjab-market accessories master list (1,726 items, version
`1.0.0` in the seed data) in `catalog_items` + `catalog_stock`, created by
migration `database/migrations/001_accessories_catalog.sql`. A catalog item
is identified by `sku` (e.g. `ACC-AUD-ANK-HP-001`). **Cashiers never
receive cost fields** (`purchase_price_est`, `last_purchase_price`) — the
server strips them for non-staff roles, like everywhere else.

| Method | Path | Role | Body / Query | Response | Notes |
| ------ | ---- | ---- | ------------ | -------- | ----- |
| GET | `/catalog` | any | `?search&category&brand&page&limit` | Paginated catalog items (each with `stockQty`, `low_stock_threshold`) | `search` matches name (EN/UR), SKU, brand. |
| GET | `/catalog/low-stock` | any | — | Items at/below `low_stock_threshold`, lowest stock first | |
| GET | `/catalog/reorder-list` | any | — | Low-stock items grouped by supplier (`{ "<supplier>": [...] }`) | Unknown supplier groups under `"Unknown supplier"`. |
| GET | `/catalog/version` | any | — | Latest catalog version `{ version, applied_at, item_count, notes }` (or `null`) | |
| GET | `/catalog/barcode/:barcode` | any | — | One catalog item | Looks up the item barcode and the permanent `barcode_links` table. Unknown barcode → 404. |
| GET | `/catalog/:sku` | any | — | One catalog item + `models` (compatible device brand/models) | Must come after the fixed paths above (`/low-stock`, `/version`, `/barcode/:barcode`) or they would match as SKUs. |
| POST | `/catalog/stock-in` | owner/manager | `{ sku, qty, price?, supplier?, date? }` | Updated catalog item | Adds `qty` to stock; records last purchase price/supplier/date. Unknown SKU → 404. |
| POST | `/catalog/bulk-stock-in` | owner/manager | `{ items: [{ sku, qty }], price?, supplier?, date? }` | `{ updated, items: [...] }` | **One transaction**: all rows or none. Duplicate SKU in the batch → 400. Max 1,000 lines. |
| POST | `/catalog/barcode-link` | owner/manager | `{ barcode, sku }` | Updated catalog item | Barcode links are permanent (first scan wins); re-linking the same barcode to a different SKU → 409. |
| POST | `/catalog/custom-item` | owner/manager | See **Create custom item** below | Created catalog item (stock 0) | For shop-specific items not in the master catalog. Duplicate SKU or barcode → 409. |
| POST | `/catalog/stock-count` | owner/manager | `{ sku, countedQty, note?, countedBy? }` | `{ ..., item }` (the stock-count row plus the updated item) | Physical count: sets stock to `countedQty` and records the difference vs. system stock. |
| POST | `/catalog/import` | owner/manager | `{ rows: [ ... ] }` or `{ csv: "<csv text>" }` | `{ matched, created, skipped, errors[] }` | See **Import** below. Max 5,000 rows. |

### Create custom item — request body

```json
{
  "sku": "ACC-CASE-SAM-A15-001",
  "category": "Covers",
  "brand": "Samsung",
  "nameEn": "Galaxy A15 Back Cover",
  "nameUr": "گیلیکسی A15 بیک کور",
  "modelCompatibility": "Galaxy A15",
  "colors": ["Black", "Blue"],
  "variants": ["Matte"],
  "purchasePriceEst": 250,
  "salePriceEst": 500,
  "minPrice": 400,
  "unit": "piece",
  "barcode": "8901234567890",
  "lowStockThreshold": 5
}
```

`sku` may only contain letters, numbers and hyphens. `nameUr`,
`modelCompatibility` and `barcode` are optional. Custom items are stored
with `is_custom = true` and are never touched by catalog version updates.

### Import

Each row is matched in order: (1) by `sku`, (2) by `barcode`, (3) by
normalised name. A matched row is a stock-in when it carries `qty > 0`.
An unmatched row with `sku` + `nameEn` becomes a new custom item;
without those it is skipped and reported in `errors[]` with its row
number. Row fields (all optional except as above): `sku`, `nameEn`,
`category`, `brand`, `nameUr`, `modelCompatibility`,
`purchasePriceEst`, `salePriceEst`, `minPrice`, `unit`, `barcode`,
`qty`, `lowStockThreshold`. When `csv` is given instead of `rows`, the
CSV header row supplies the same field names.

---

## Testing

```bash
cd backend
npm install
npm run lint        # tsc --noEmit (src + tests)
npm run build       # tsc -> dist/
npm test            # vitest run
npm run dev         # tsx watch src/server.ts (port 3000 by default)
```

`tests/money.test.ts` — money math (line totals, bill totals, discounts, tax,
profit, installments, expected cash).
`tests/billing.test.ts` — full-bill scenarios (mixed phone + accessory bill,
bill discount, partial/udhaar balances, return refund split).
`tests/api.test.ts` — HTTP tests via supertest (health, auth guard, Zod
validation, 404 envelope). These need **no database** — they only exercise
code paths that run before any DB access.

Full DB-backed API tests (create a bill, pay a supplier, close the register)
need a test database: create a database, run `database/schema.sql` against
it, set `DATABASE_URL` in `.env`, and run the server. They are not in this
module's test suite.

## Running the server

```bash
# 1. Create the database and load the schema (from the project root):
createdb shopdb
psql -d shopdb -f database/schema.sql

# 2. Configure:
cp backend/.env.example backend/.env
# edit DATABASE_URL, JWT_ACCESS_SECRET, JWT_REFRESH_SECRET, PORT

# 3. Run:
cd backend && npm install && npm run dev
# Health: curl http://localhost:3000/health
```

The first user must be created directly in the database (there is no public
signup endpoint): insert a row into `users` with a bcrypt hash (cost 12) and
a `role_id` from the `roles` table (`owner` / `manager` / `cashier`), then
log in with `POST /api/v1/login`.

---

## Notes & known limitations (for the next module)

1. **Schema bug (Module 3) — FIXED.** The `ALTER TABLE payments ADD
   CONSTRAINT fk_pay_repair ... REFERENCES repairs(id)` that used to run
   before the `repairs` table existed now runs after it
   (`database/schema.sql`: the FK is added in the repairs section, with a
   comment noting the original ordering bug). A fresh `psql -f schema.sql`
   no longer fails on this.
2. **Accessories catalog module IS mounted** at `/api/v1/catalog`
   (`app.ts`: `api.use('/catalog', catalogRoutes)`), with the migration
   `database/migrations/001_accessories_catalog.sql` applied (1,726 items,
   version `1.0.0` in the seed data). Its **12 endpoints are counted** in
   the 113 below — see §11.
3. **Repair technician:** the schema has no technician column on `repairs`
   (only `user_id`, the creator). Technician assignment needs a schema change.
4. **Bill cancel is owner-only.** The seed role permissions say
   `manager.sales.cancel = false`; the service comment says owner/manager.
   The route enforces owner-only to match the seed.
5. **Refresh tokens are stateless JWTs** (no refresh-token table in the
   schema); logout is client-side token discard.
6. **bcryptjs, not bcrypt** (pure JS, no native build tools needed on the
   user's Windows; same API, cost 12).
7. **NUMERIC → number:** `pg` parses `NUMERIC(12,0)` with `parseInt` in
   `config/db.ts`, so all money arrives as JS numbers (exact for whole PKR).
8. **Branch scoping:** sales, purchases, expenses, cash register and repairs
   (via the counter) are branch-aware; `payments`, `salary_payments`,
   `installments` and `service_sales` have no `branch_id` in the schema, so
   their branch is resolved through the linked sale/purchase/user where the
   report needs one. Single-branch shops are unaffected.
9. **Expenses are cash** in the day-end math (the schema has no payment-method
   column on expenses).
10. **Invoice numbers** come from the `counters` table (`sale_invoice` /
    `INV`, `repair_job` / `REP`), locked `FOR UPDATE` inside the transaction
    so two concurrent bills can never share a number.

## Endpoint count

**113 API endpoints + 1 health check = 114 mounted routes.**
Auth 10 · Products 19 · Sales 11 · Purchases & Suppliers 10 · Customers &
Installments 11 · Repairs & Service Sales 9 · Expenses, Staff, Salaries &
Cash Register 16 · Reports 10 · Settings 2 · Sync 3 · Catalog 12.
