# System Architecture — Detailed Design

> Module 1 (continued) · Baba Farid Mobiles Billing & Inventory System
> Currency: PKR · Languages: English + Urdu (RTL-ready) · Offline-first

---

## 1. Design principles

1. **Offline-first, always.** The shop must never stop because the internet
   did. Every sale, purchase and payment is written to local SQLite first,
   then synced. A bill must print even with zero connectivity.
2. **Money is append-only.** Sales, payments, ledger entries and audit logs
   are never edited in place. Corrections are new entries (return, reversal,
   adjustment) that reference the original. This makes the books auditable
   and prevents lost or double-counted money.
3. **One source of truth for stock.** A phone is a unique IMEI item; an
   accessory is a quantity. Stock changes only through a sale, purchase,
   return, or an explicit stock adjustment (which is audit-logged).
4. **Simple for the shopkeeper.** Big buttons, Urdu + English, no jargon.
   The POS screen is the home screen; everything else is one tap away.
5. **Secure by default.** Passwords are bcrypt-hashed, API access is
   JWT + role-checked, all input is validated, SQL is parameterised, and
   local data is encrypted at rest where the platform allows it.

## 2. Components

### 2.1 Flutter app (Android + Web)

- **Presentation layer** — screens (POS, Inventory, Customers, Ledger,
  Repairs, Reports, Settings), large touch targets, dark/light theme,
  English/Urdu switch (Urdu uses RTL layout).
- **Domain layer** — pure Dart business rules: bill math (discount, tax,
  totals, rounding to whole PKR), IMEI uniqueness, minimum-price check,
  installment schedule generation. Fully unit-tested (Module 9).
- **Data layer** — local SQLite (via `drift`) is the primary store on the
  device; a repository pattern hides whether data comes from local DB or
  the API. An API client talks to the backend with the JWT.
- **Sync engine** — an outbox table records every local mutation; a
  background job pushes the outbox and pulls server changes (Module 7).
- **Device services** — thermal printer (Bluetooth/USB ESC/POS), camera
  barcode/QR scan (IMEI), PDF generation, WhatsApp share, file backup.

### 2.2 Backend (Node.js + Express + TypeScript)

- **REST API** under `/api/v1`, JSON everywhere, consistent response
  envelope: `{ ok, data, error }`.
- **Auth** — JWT access token (short-lived) + refresh token; bcrypt
  passwords; role middleware (`requireRole('admin' | 'manager' |
  'cashier')`); cashiers never receive cost-price fields (the API strips
  them based on role).
- **Validation** — every request body is validated (Zod schemas); invalid
  input is rejected with a clear error before touching the database.
- **Transactions** — a sale (bill + items + stock deduction + ledger +
  cash entry) is one database transaction. It either fully succeeds or
  fully rolls back. Never a half-saved bill.
- **Audit** — every mutating request writes an audit-log row (user, action,
  entity, before/after, timestamp, device).
- **Money** — PostgreSQL `NUMERIC(12,0)` (whole rupees) for all money
  columns; all calculations in integers; rounding only at display.

### 2.3 PostgreSQL (server)

- One database, tables per the ER design (Module 3): users, roles,
  products, product_variants, imei_items, categories, brands, customers,
  suppliers, sales, sale_items, purchases, purchase_items, payments,
  ledger_entries, installments, repairs, expenses, cash_register,
  audit_logs, settings.
- Foreign keys everywhere; unique constraint on IMEI; partial unique index
  so a sold IMEI cannot be sold twice; check constraints (prices ≥ 0,
  quantity ≥ 0).

### 2.4 Peripherals & external services

| Service | Use |
|---|---|
| Thermal printer (58/80mm, BT/USB) | Receipts at the counter |
| Camera barcode/QR scan | IMEI + product barcode entry |
| WhatsApp | Share invoice PDF / payment reminders |
| SMS gateway | Installment due-date reminders |
| Google Drive / cloud | Backup & restore |

## 3. Key data flows

### 3.1 Selling a phone (POS)

```
Cashier scans/searches phone → app shows the IMEI item (New, PTA Approved)
→ adds to cart → discount (Rs or %) → payment (Cash / JazzCash / Easypaisa /
Bank / Card / Partial / Udhaar) → SAVE
→ (one DB transaction) sale + sale_items saved, IMEI marked SOLD,
  stock deducted, customer ledger updated (if udhaar), cash register
  updated, audit log written → receipt printed (thermal) / PDF / WhatsApp
```

Business rules enforced in this flow: IMEI must be AVAILABLE (not already
sold); sale price below minimum price requires admin approval (admin PIN);
totals are whole PKR; cashier never sees purchase cost.

### 3.2 Buying stock (Purchase)

```
Manager creates purchase → supplier + invoice no. + date → adds IMEI list
(or accessory quantities) with cost → SAVE
→ (one transaction) purchase + purchase_items saved, IMEI items created
  as AVAILABLE with purchase cost, accessory quantities increased,
  supplier payable increased, audit log written
```

### 3.3 Return / exchange

```
Cashier opens old bill → Return item (or Exchange for another item)
→ (one transaction) return record saved, IMEI returned to AVAILABLE
  (or exchanged IMEI marked SOLD, new IMEI marked SOLD), stock adjusted,
  customer ledger credited, cash refunded/adjusted, audit log written
```

### 3.4 Installment sale

```
Sale on installments → down payment now, remaining split into N
installments with due dates → each due date generates a reminder
(SMS/WhatsApp) → customer pays an installment → ledger + cash updated,
installment marked PAID, receipt issued
```

### 3.5 Day close (cash)

```
Opening cash (morning) → sales, expenses, cash-in/out during the day
→ Closing: app shows expected cash (opening + cash sales − expenses −
refunds + cash-in − cash-out) → cashier counts physical cash, enters
actual → difference recorded → day-end summary (printable)
```

## 4. Offline sync design (summary; full design in Module 7)

- **Local first:** all screens read from local SQLite, so the app is fast
  and works offline.
- **Outbox:** every local mutation (sale, payment, stock change, customer
  add…) is also written to an `outbox` table with a unique client-side ID.
- **Push:** when online, the sync job sends outbox rows in order to
  `POST /api/v1/sync/push`. The server applies them idempotently (same
  client ID = same result, never applied twice).
- **Pull:** the client asks `GET /api/v1/sync/pull?since=<timestamp>` and
  applies server changes (new products, price updates, other-device sales).
- **Conflicts:** master data (product name/price) → server wins, client
  re-applies its own later change as a new version. Money records (sales,
  payments, ledger) → append-only, never overwritten, so nothing is lost.
- **IMEI safety:** the server is the final authority on IMEI status. If
  two devices sell the same IMEI offline, the first one synced wins; the
  second gets a clear conflict error and the sale is flagged for the owner
  to resolve (the phone is physically in only one shop, so this is rare
  and always visible).

## 5. Security

- **Passwords:** bcrypt (cost factor 12), never stored or logged in plain
  text. Login rate-limited (5 failed attempts → temporary lockout).
- **Tokens:** JWT access (15 min) + refresh (7 days, revocable). Tokens
  are sent as `Authorization: Bearer <token>`.
- **Roles:** enforced in middleware on every endpoint; the API never
  returns cost prices to cashiers.
- **Input:** Zod validation on every request; parameterised SQL only
  (no string-built queries); output escaping to prevent XSS.
- **Local data:** SQLite database encrypted where the platform supports
  it; auth token stored in secure storage (not plain preferences).
- **Audit:** every create/update/delete records user, role, action,
  entity, timestamp and device.

## 6. Performance targets

| Target | Goal |
|---|---|
| App cold start | < 2 seconds |
| POS screen: scan → item in cart | < 1 second |
| Bill save (local) | < 500 ms |
| Product search (10k+ products) | < 200 ms (local indexed search) |
| Report (monthly) | < 2 seconds (server, indexed queries) |

## 7. Deployment topology

```
Shop counter (Android phone/tablet)
   ├── Flutter app (offline-first, SQLite)
   ├── Bluetooth thermal printer
   └── Internet (when available) → Backend API (Node.js, hosted VPS/cloud)
                                      └── PostgreSQL (same host or managed DB)
Owner's phone/laptop
   └── Flutter Web admin panel → same backend API
Backup
   └── Daily local backup file + Google Drive upload
```

- **Single shop first:** one backend, one database, all devices sync to it.
- **Multi-branch (optional, later):** a `branch_id` on every record; the
  same API and sync protocol; branches see only their own data unless the
  owner enables cross-branch reports.

## 8. What Module 2 already delivered

The complete folder structure (see `README.md` §6) and the empty project
folders have been created under `mobile-shop-billing-system/`. The next
modules fill them in, in order: database schema → backend API → Flutter
app → printing/PDF → sync → deployment → seed data & tests.
