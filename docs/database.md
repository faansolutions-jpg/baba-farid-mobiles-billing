# Database Design — ER Diagram & Schema Notes

> Module 3 · Baba Farid Mobiles Billing & Inventory System
> Full SQL: `database/schema.sql` (PostgreSQL 16) · Currency: PKR, whole rupees

---

## 1. ER diagram

```
                          ┌──────────────┐
                          │   branches   │
                          │ (multi-      │
                          │  branch opt.)│
                          └──────┬───────┘
                                 │ 1 ── N
              ┌──────────────────┼──────────────────┐
              ▼                  ▼                  ▼
       ┌────────────┐    ┌──────────────┐    ┌──────────────┐
       │   users    │    │    sales     │    │  purchases   │
       │ (role via  │    │  invoice_no  │    │  supplier    │
       │  roles)    │    │  grand_total │    │  invoice no. │
       └─────┬──────┘    │  paid/balance│    └──────┬───────┘
             │           └──────┬───────┘           │
             │ 1 ── N           │ 1 ── N            │ 1 ── N
             ▼                  ▼                   ▼
       ┌────────────┐    ┌──────────────┐    ┌──────────────┐
       │ audit_logs │    │  sale_items  │    │purchase_items│
       │ (who, what │    │  + profit    │    │ (IMEI list)  │
       │  when)     │    │  per item    │    └──────┬───────┘
       └────────────┘    └──────┬───────┘           │
                                │                   ▼
              ┌─────────────────┼───────────────────┐
              ▼                 ▼                   ▼
       ┌────────────┐    ┌──────────────┐    ┌──────────────┐
       │  products  │    │ product_     │    │  imei_items  │
       │  (phone /  │───►│  variants    │───►│  imei1 UNIQUE│
       │  accessory)│1─N │ (price, qty, │1─N │  status:     │
       └─────┬──────┘    │  PTA, cond.) │    │  available / │
             │           └──────────────┘    │  sold / ...  │
             │  N ── 1                       └──────┬───────┘
             ▼                                      │
       ┌────────────┐                               │ sold via
       │  brands /  │                               ▼
       │ categories │                        ┌──────────────┐
       └────────────┘                        │ sale_returns │
                                             │ (append-only)│
                                             └──────────────┘

  ┌────────────┐      ┌──────────────┐      ┌──────────────┐
  │ customers  │──1─N─► ledger_     │      │ installments │
  │ (phone,    │      │ entries      │      │  + installment│
  │  CNIC)     │      │ (running     │      │  _payments    │
  └─────┬──────┘      │  balance)    │      │ (due dates,   │
        │             └──────────────┘      │  reminders)   │
        │ 1 ── N                            └──────┬───────┘
        ▼                                          │ paid via
  ┌────────────┐                              ┌──────────────┐
  │  repairs   │──1─N──► repair_parts         │   payments   │
  │ (job card) │                              │ (sale / purch│
  └────────────┘                              │  / inst. /   │
        ▲                                     │  repair)     │
        │                                     └──────────────┘
  ┌────────────┐      ┌──────────────┐      ┌──────────────┐
  │ suppliers  │──1─N─► ledger_     │      │ cash_register│
  │ (payable)  │      │ entries      │      │ + cash_      │
  └────────────┘      └──────────────┘      │ movements    │
                                             └──────────────┘
  ┌────────────┐      ┌──────────────┐      ┌──────────────┐
  │  expenses  │      │ staff /      │      │ settings /   │
  │ (by categ.)│      │ salary_      │      │ counters /   │
  └────────────┘      │ payments     │      │ sync_logs /  │
                      └──────────────┘      │ audit_logs   │
                                            └──────────────┘
```

## 2. Table list (33 tables)

| Group | Tables |
|---|---|
| Organisation | `branches`, `roles`, `users` |
| Catalog | `categories`, `brands`, `products`, `product_variants` |
| IMEI stock | `imei_items` |
| People | `customers`, `suppliers` |
| Sales | `sales`, `sale_items`, `sale_returns`, `held_bills` |
| Purchases | `purchases`, `purchase_items`, `purchase_returns` |
| Money | `payments`, `ledger_entries`, `installments`, `installment_payments` |
| Service | `repairs`, `repair_parts`, `service_sales` |
| Cash & staff | `expenses`, `staff`, `salary_payments`, `cash_register`, `cash_movements` |
| System | `audit_logs`, `settings`, `counters`, `sync_logs` |

## 3. Key design decisions

### 3.1 UUID primary keys (offline-first)
Every table uses `UUID DEFAULT gen_random_uuid()`. A phone can create a
sale, a customer, or a product **offline** and the ID will never collide
with another device's records when they sync. Integer sequences would
collide across devices; UUIDs do not.

### 3.2 Money = whole PKR, always
Every money column is `NUMERIC(12,0)` — whole rupees, no paisa decimals.
All calculations are done in integers (rupees), so there is no floating
point rounding error. Display formatting (e.g. `Rs 49,000`) happens only
in the UI. The `CHECK (amount >= 0)` constraints reject negative money.

### 3.3 Phones vs accessories — two stock models in one catalog
- **Phone** = a `product` (e.g. Galaxy A15) + `product_variant`
  (8GB/128GB, Black, New, PTA Approved) + one `imei_items` row **per
  physical phone**. Stock = `COUNT(imei_items WHERE status='available')`.
- **Accessory** = a `product` + `product_variant` with a `quantity`
  column. Stock is a number that goes up/down.
- This keeps one catalog, one search, one billing flow — the app only
  differs in how stock is counted.

### 3.4 IMEI can never be sold twice
- `imei_items.imei1` is `UNIQUE` — the same IMEI can never be entered
  twice, on any device.
- `imei_items.imei2` is `UNIQUE` where present.
- A sale only accepts an IMEI whose `status = 'available'`. Selling sets
  it to `'sold'` (and records `sold_sale_id`) inside the **same database
  transaction** as the bill — so two bills can never claim one phone.
- A return sets the IMEI back to `'available'` (or `'returned'` for
  inspection) — again in the same transaction as the return record.
- `idx_imei_sold` (partial index) makes "find all sold IMEIs" instant.

### 3.5 Money is append-only
`sales`, `payments`, `ledger_entries`, `audit_logs` are never edited in
place. A mistake is fixed by a **new** record that references the old one
(`sale_returns`, a reversing `ledger_entries` row, a new `payments` row).
Consequences:
- The books are always auditable: every rupee can be traced.
- Offline sync can never silently overwrite money: new rows just append.
- `sale_items.profit` is stored per line (sale − cost) so profit reports
  never need to re-derive history after a price change.

### 3.6 Ledger with running balance
`ledger_entries` stores `debit`, `credit`, and `balance_after` for every
customer and supplier. The current balance is simply the latest row's
`balance_after` — no expensive `SUM()` over history for the common case,
and the full history is there for statements. Opening balances are the
first entry (`reference_type = 'opening'`).

### 3.7 Installments
`installments` holds the plan (total, down payment, count, per-installment
amount, start date). `installment_payments` holds one row per due date
with its own status (`pending` / `partial` / `paid` / `overdue`) and a
`reminder_sent` flag so reminders are never sent twice.

### 3.8 Cash register (day close)
One `cash_register` row per branch per day (`UNIQUE(branch_id,
register_date)`). `expected_cash` is computed by the system
(opening + cash sales − expenses − refunds + cash-in − cash-out);
`closing_cash` is what the cashier physically counts; `difference` is
recorded. `cash_movements` records every cash-in/out during the day.

### 3.9 Idempotent sync
Money tables (`sales`, `purchases`, `payments`) carry a `client_uuid`
(`UNIQUE`). When a device syncs an offline sale, the server applies it
only if that `client_uuid` is new — retrying the same sync can never
create a duplicate bill. `sync_logs` records what each device synced,
for debugging.

### 3.10 Audit trail
`audit_logs` records every mutating action: `user_id`, `action`
(create/update/delete/login/sale/payment…), `entity_type`, `entity_id`,
`old_values` / `new_values` (JSONB snapshots), IP and device info.
It is append-only and readable only by Owner/Admin.

## 4. Business rules → where they are enforced

| Rule (from spec §5) | Enforced by |
|---|---|
| Sold IMEI never sold again unless returned | `imei_items.imei1 UNIQUE` + `status='available'` check + same-transaction sale; `idx_imei_sold` |
| Sale below minimum price needs admin approval | `product_variants.min_price` + API rule: price < min_price requires an admin's approval flag/PIN (Module 4) |
| Stock auto-deducted on sale, auto-added on purchase/return | Sale/purchase/return transactions update `imei_items.status` and `product_variants.quantity` in the same transaction (Module 4) |
| Profit = sale − purchase cost, per item | `sale_items.purchase_cost` snapshot + stored `profit` per line |
| All money accurate, rounded to whole PKR | `NUMERIC(12,0)` everywhere + integer math + `CHECK` constraints |

## 5. Indexes — why these

- **Foreign keys** (`sales.customer_id`, `sale_items.sale_id`, …) — joins
  in reports and ledger statements.
- **Dates** (`sales.sale_date`, `payments.payment_date`,
  `expenses.expense_date`) — daily/weekly/monthly reports.
- **Status** (`imei_items.status`, `repairs.status`,
  `installment_payments.due_date + status`) — "what is available?",
  "what is overdue?", "what is ready?" lists.
- **Search** — `products.name` and `customers.name` use trigram-style
  full-text (`to_tsvector`) indexes so POS search stays fast at 10k+
  products; `customers.phone` and `repairs.imei` are plain B-tree
  lookups.
- **Uniqueness** — `invoice_no`, `job_no`, `imei1`, `imei2`, `barcode`,
  `users.phone`, `client_uuid`, `(branch_id, register_date)`.

## 6. How to create the database

```bash
# 1. Create the database
createdb shopdb

# 2. Run the schema (creates all 30 tables, enums, indexes, seed roles)
psql -d shopdb -f database/schema.sql

# 3. Verify
psql -d shopdb -c "\dt"          # list tables (expect 30)
psql -d shopdb -c "SELECT * FROM roles;"
psql -d shopdb -c "SELECT key, value FROM settings;"
```

> The seed at the bottom of `schema.sql` creates the first branch (Baba
> Farid Mobiles), the three roles (owner/manager/cashier) with their
> permissions, and the shop profile settings. The first Owner user is
> created by the backend (Module 4) or the seed script (Module 9).
> Full sample data (products, customers, suppliers, bills) is in Module 9.
