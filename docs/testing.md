# Testing Guide — Baba Farid Mobiles Billing & Inventory System

> Module 9 · Shop: Baba Farid Mobiles, Pakpattan · Currency: PKR (whole rupees)
> Related: `database/schema.sql`, `database/seed.sql`, `docs/sync.md`,
> `docs/deployment.md`, `PLAN.md` (verification section), `DECISIONS.md`.

---

## 1. What to test

There are two test suites, one per codebase:

| Suite | Location | Runner | Command |
|---|---|---|---|
| Backend unit + API tests | `backend/tests/` | Vitest (+ Supertest) | `npm test` (runs `vitest run`) |
| Flutter unit + widget tests | `mobile_app/test/` | Flutter test | `flutter test` |

> **Status note (2026-11-16):** both test directories currently exist but
> are empty — the test files themselves are written by the Module 4 backend
> agent (backend) and the Round 3 verification agent. The commands below are
> the commands those suites use; do not expect them to pass until the test
> files land. This guide describes what the suites must cover.

### 1.1 Backend tests — `cd backend && npm test`

```bash
cd backend
npm install          # once
npm test             # vitest run — unit + API tests, exits with a summary
npm run test:watch   # vitest in watch mode while developing
npx tsc --noEmit     # typecheck (also the `npm run lint` script)
```

What the backend suite must cover (per `PLAN.md`):

- **Bill math** — subtotal, discount (Rs and %), tax, grand total, paid +
  balance = grand total; all money whole PKR integers, no paisa.
- **Profit** — `profit = total − purchase_cost × quantity` per sale item.
- **IMEI rules** — a sale of an IMEI whose status is not `available` is
  rejected; a sold IMEI can never be sold again unless its sale is returned.
- **Minimum price** — a sale below `product_variants.min_price` is rejected
  unless admin approval is supplied (`admin_approved_by`).
- **Partial payment** — `payment_status = 'partial'`, `balance_due` correct,
  ledger debit equals the balance, and a later payment reduces it.
- **Returns** — a return restores the IMEI to `available` (or accessory
  quantity), credits the customer ledger, and never edits the original sale.
- **Installments** — schedule generation (down payment + N equal parts),
  overdue flag when `due_date < today` and unpaid.
- **Roles** — cashier requests never receive cost prices; cashier cannot
  cancel sales or edit settings; owner can do everything.
- **Sync idempotency** — pushing the same `client_uuid` twice applies once.
- **Auth** — wrong password rejected; 5 failed logins → 15-minute lockout;
  expired access token rejected; refresh token flow works.

Run the backend tests against a **separate test database** (never the live
shop database). The API tests create their own schema from
`database/schema.sql` + `database/seed.sql` and drop it afterwards.

### 1.2 Flutter tests — `cd mobile_app && flutter test`

```bash
cd mobile_app
flutter pub get
flutter test              # unit + widget tests
flutter test test/domain/ # one folder only
flutter analyze           # 0 errors required before release
```

What the Flutter suite must cover:

- **Domain (pure Dart, no device needed)** — bill math, installment
  schedule generation, IMEI validation (15 digits, unique), min-price check,
  money formatting (`formatPkr`), discount math.
- **Repositories / data layer** — local SQLite (drift) CRUD, outbox rows
  written for every local mutation, sync push/pull mapping.
- **Widget tests** — POS screen (scan → cart → totals → save < 1 s),
  login screen, low-stock badge, Urdu/English toggle.

> Flutter/Dart SDK is not installed on this machine (see `DECISIONS.md`
> §30), so `flutter test` / `flutter analyze` cannot be run here yet.
> Install Flutter first — see `docs/deployment.md` §2 — or verify the pure
> Dart domain logic with the Dart SDK if available.

---

## 2. Seed data — setting up a test database

The seed file gives you a realistic shop to test against. It is idempotent
(`INSERT ... ON CONFLICT DO NOTHING` with fixed UUIDs) — safe to re-run.

```bash
createdb shopdb
psql -d shopdb -f database/schema.sql   # creates the 33 tables + roles + branch
psql -d shopdb -f database/seed.sql    # loads the demo shop
```

**What the seed contains** (see the header comment in `seed.sql` for the
full consistency notes):

| Table | Rows | Highlights |
|---|---|---|
| roles / users | 3 / 3 | admin, manager, cashier (see logins below) |
| categories / brands | 7 / 15 | Phones, Chargers, Audio, Covers & Glass, Power, Storage … |
| products / product_variants | 21 / 26 | Galaxy A16, Hot 50, Spark 30, Redmi Note 13, Vivo Y28, Oppo A18, itel A70, used iPhone 13, Nokia 105 + 9 accessories |
| imei_items | 30 | 5 sold, 25 available; 15-digit IMEIs |
| customers / suppliers | 10 / 2 | Hassan Mobile Traders (payable 244500), Bilal Electronics (payable 157500) |
| purchases / purchase_items | 3 / 39 | PUR-001 451000 paid in full; PUR-002 457500 (paid 300000); PUR-003 944500 (paid 700000) |
| sales / sale_items | 5 / 10 | INV-000001…INV-000005; total profit 28770 |
| sale_returns | 1 | Tempered glass from INV-000001, refund 400 |
| payments | 10 | Sale + purchase + repair payments; add up to each bill's `paid_amount` |
| ledger_entries | 12 | Customer udhaar: Bilal 14000, Usman 24000, Asif 38000, Hassan Ali 5000, Ali Hamza 15000 |
| installments / installment_payments | 2 / 7 | Usman Ghani 3×8000 (first due 15 Nov 2026 — **overdue**); Muhammad Asif 4×9500 |
| repairs / repair_parts | 2 / 1 | REP-000001 Infinix Hot 50 screen — **ready**; REP-000002 Galaxy A15 battery — in progress |
| service_sales | 2 | EasyLoad Jazz 1000, MEPCO bill payment 5000 |
| expenses | 4 | Rent 35000, electricity 8200, transport 3500, misc 1200 |
| staff / salary_payments | 2 / 1 | October salary paid to Muhammad Bilal |
| cash_register / cash_movements | 1 / 2 | 16 Nov 2026, opening 50000, still **open** |
| held_bills | 1 | Parked bill (charger) for a walk-in customer |
| counters | 3 | Next invoice INV-000006, next repair REP-000003, next purchase PUR-004 |
| audit_logs / sync_logs | 3 / 2 | Sample trail rows |

**Demo logins** (bcrypt, cost 12 — **change after first login**):

| Username | Password | Role | Person |
|---|---|---|---|
| `admin` | `admin123` | Owner | Anas Zaheer |
| `manager` | `manager123` | Manager | Naeem Ahmad |
| `cashier` | `cashier123` | Cashier | Bilal Ahmed |

### 2.1 Verify the seed loaded correctly

Run the verification queries at the bottom of `database/seed.sql`, or these
quick checks (expected values in brackets):

```sql
SELECT count(*) FROM imei_items WHERE status = 'available';          -- [25]
SELECT count(*) FROM imei_items WHERE status = 'sold';               -- [5]
SELECT sum(profit) FROM sale_items;                                  -- [28770]
SELECT * FROM installment_payments WHERE status = 'overdue';         -- [1 row, Rs 8000]
-- Sale totals: expect 0 rows (every sale's items sum to its totals)
SELECT s.invoice_no FROM sales s
 WHERE s.grand_total <> (SELECT COALESCE(sum(total),0) FROM sale_items WHERE sale_id = s.id)
    OR s.paid_amount + s.balance_due <> s.grand_total;
-- Purchase totals: expect 0 rows
SELECT p.id FROM purchases p
 WHERE p.grand_total <> (SELECT COALESCE(sum(total),0) FROM purchase_items WHERE purchase_id = p.id)
    OR p.paid_amount + p.balance_due <> p.grand_total;
```

To reset the demo data, drop and recreate the database — never delete rows
by hand (the seed's foreign keys and running balances depend on each other):

```bash
dropdb shopdb && createdb shopdb
psql -d shopdb -f database/schema.sql
psql -d shopdb -f database/seed.sql
```

---

## 3. End-to-end scenario (the happy path)

Do this on the seeded database, in order, and check the result after each
step. It exercises every module in one pass.

### Step 1 — Purchase phones (Manager)

1. Log in as `manager` / `manager123`.
2. Create a purchase from **Hassan Mobile Traders**: supplier invoice
   `HMT-2026-1116`, 2 × Samsung Galaxy A16 (8/128, Black) at 48500 each.
3. Enter two new IMEIs (15 digits, not already in the system), e.g.
   `860123456789021` and `860123456789022`.
4. Save. **Check:** 2 new `imei_items` with status `available`,
   purchase total 97000, supplier payable increased by 97000, audit log row
   written.

### Step 2 — Sell with partial payment (Cashier)

1. Log in as `cashier` / `cashier123`.
2. Create a bill for customer **Bilal Hussain** (03023456789 — already owes
   14000 udhaar).
3. Scan/add IMEI `860123456789021` (Galaxy A16, 54000) + 1 × Tempered Glass
   9H (400). Subtotal should be 54400.
4. Give Rs 400 discount → grand total 54000.
5. Take **Rs 30000 cash** as a partial payment (payment method: Partial).
6. Save and print the invoice. **Check:** sale `INV-000006`,
   `paid_amount` 30000, `balance_due` 24000, `payment_status` `partial`;
   IMEI `860123456789021` is now `sold` with `sold_sale_id` = the new sale;
   glass quantity dropped by 1; Bilal's ledger balance is now
   14000 + 24000 = **38000**; cash register expected cash increased by 30000.

### Step 3 — Print the invoice

1. From the sale, print the thermal receipt (58/80mm) — or, with no printer
   connected, generate the A4 PDF.
2. **Check:** shop name/address/phones, invoice number, date, items with
   IMEI printed, discount, totals, paid/balance, and the QR warranty code
   (see `DECISIONS.md` §19 — the QR opens the in-app IMEI-history lookup).
3. Share the PDF on WhatsApp to the customer's number (wa.me share link).

### Step 4 — Return an item

1. Open `INV-000006` → Return → select the tempered glass → reason
   "customer changed mind" → refund Rs 400.
2. **Check:** a `sale_returns` row exists (refund 400); the sale status is
   now `partially_returned`; the glass quantity is back up by 1; the
   customer's ledger is credited 400 (balance 37600); the original sale row
   was **not** edited (money is append-only); the phone IMEI stays `sold`.

### Step 5 — Check the ledger

1. Open Bilal Hussain's ledger. **Check:** the running balance reads 37600
   and the entries, in order, are: opening seed rows → INV-000002 udhaar →
   JazzCash recovery → INV-000006 udhaar → glass return credit.
2. Record a Rs 10000 udhaar recovery from Bilal (cash). **Check:** balance
   drops to 27600 and a `payments` row (type `udhaar_recovery`) exists.

### Step 6 — Check the reports

1. Open Dashboard → today's sales: the new sale (54000) appears; today's
   profit includes the A16 profit (54000 − 48500 = 5500) minus the returned
   glass profit.
2. Open Reports → P&L (November): revenue, cost of goods, gross profit,
   expenses (rent 35000 + electricity 8200 + transport 3500 + misc 1200 =
   47900) all reconcile with the seed + the new transactions.
3. Open Stock Valuation: 2 × A16 bought, 1 sold → 1 left (plus the second
   IMEI still available); low-stock list shows any variant at/below its
   `low_stock_threshold`.
4. Open Pending Udhaar: Bilal Hussain 27600, Usman Ghani 24000,
   Muhammad Asif 38000, Hassan Ali 5000, Ali Hamza 15000.
5. Open Overdue Installments: Usman Ghani's Rs 8000 (due 15 Nov 2026) is
   still listed until it is paid.

**Pass criteria:** every check above matches exactly, no error toasts, and
no half-saved state (if any step fails, the whole transaction rolls back).

---

## 4. Edge-case checklist

Run each case and confirm the expected result. Tick it off in `CHECKLIST.md`
when it passes.

| # | Edge case | How to test | Expected result |
|---|---|---|---|
| 1 | **Duplicate IMEI** | Add a purchase item with IMEI `860123456789011` (already in the seed, sold on INV-000001). Also try scanning the same IMEI twice on one purchase. | Rejected with a clear error ("IMEI already exists"). No row saved. The database `UNIQUE` constraint on `imei_items.imei1` is the last line of defence. |
| 2 | **Sell an already-sold IMEI** | Try to sell IMEI `860123456789011` again on a new bill. | Rejected — only `status = 'available'` IMEIs can be added to a cart. |
| 3 | **Sale return** | Return the phone from INV-000001 (Galaxy A16, IMEI `860123456789011`). | IMEI returns to `available`, `sold_sale_id` cleared, customer ledger credited, cash refunded, sale status becomes `returned`/`partially_returned`, original sale untouched. |
| 4 | **Partial payment** | Sell a phone for 54000, take 10000. | `payment_status` `partial`, `balance_due` 44000, ledger debit 44000. Pay the remaining 44000 later → status `paid`, balance 0. |
| 5 | **Installment overdue** | Open the overdue list on/after 16 Nov 2026. | Usman Ghani's Rs 8000 (due 15 Nov 2026) shows as `overdue` with a reminder flag. Paying it marks that row `paid` and leaves the other two `pending`. |
| 6 | **Offline sale then sync** | Turn off internet/Wi-Fi, make a sale, print the receipt, then go online. | Sale saves and prints offline (local SQLite + outbox). On reconnect it syncs once — the server has exactly one copy (same `client_uuid` is never applied twice). See `docs/sync.md`. |
| 7 | **Permission denied** | Log in as `cashier`, try to: view a purchase cost, cancel a sale, open Settings → Users, open the profit report. | Cost prices are hidden/stripped from the API response; cancel/settings/profit are denied with a clear message. Log in as `manager`: profit visible, settings still denied. Log in as `owner`: everything allowed. |
| 8 | **Below-min-price sale** | Try to sell the Galaxy A16 (min price 52000) for 50000 as cashier. | Rejected without admin approval. Enter the admin PIN / owner approval → allowed, and the approval (who approved) is recorded in the audit log. |
| 9 | **Discount bigger than subtotal** | Apply a Rs 60000 discount to a Rs 54000 bill. | Rejected (database `CHECK (discount_amount <= subtotal)` + app validation). |
| 10 | **Paid more than grand total** | Enter paid amount 60000 on a 54000 bill. | Rejected (database `CHECK (paid_amount <= grand_total)`). |
| 11 | **Walk-in customer** | Sell without selecting a customer. | Allowed; `customer_id` NULL, `customer_name` "Walk-in Customer", no ledger entry created. |
| 12 | **Held bill** | Park a bill mid-sale, serve another customer, resume the parked bill. | Cart restored exactly (items, quantities, discount); the seeded held bill (charger, Rs 2000) is a ready-made example. |
| 13 | **Day close with a difference** | Close the 16 Nov register with counted cash different from expected. | `difference` (actual − expected) is recorded, the register status becomes `closed`, and a new register must be opened before the next sale. |
| 14 | **Return more than sold** | Return quantity 2 of an item sold once. | Rejected — return quantity cannot exceed the sold quantity. |
| 15 | **Concurrent IMEI sale (two devices)** | Sell the same available IMEI on two offline devices, then sync both. | First sync wins; the second gets a conflict error and the sale is flagged for the owner to resolve (see `docs/sync.md` §5). The phone is never double-sold. |

---

## 5. Regression checklist (run before every release)

- [ ] `cd backend && npm test` — all green; `npx tsc --noEmit` — 0 errors.
- [ ] `cd mobile_app && flutter test` — all green; `flutter analyze` — 0 errors.
- [ ] Seed loads cleanly on a fresh database (section 2 checks all pass).
- [ ] End-to-end scenario (section 3) passes on the seeded database.
- [ ] Edge cases 1–8 (section 4) all pass.
- [ ] `npm audit` in `backend/` — no high/critical issues, or documented.
- [ ] Demo passwords changed on any shared/demo deployment.
- [ ] Backup/restore round-trip works (see `docs/deployment.md` §5).
