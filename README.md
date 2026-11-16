# Baba Farid Mobiles — Billing & Inventory Management System

> **Module 1 of 9** — Project Overview & System Architecture
> Currency: **PKR (Pakistani Rupees)** · Languages: **English + Urdu (RTL-ready)**
> Shop: Baba Farid Mobiles, Jamal Chowk, Depalpur Road, Pakpattan
> Contacts: Naeem Ahmad +92 302 4988560 · Anas Zaheer +92 329 9966771 · baba.farid.mobiles.bfw@gmail.com

---

## 1. What this system is

A complete, production-ready billing and inventory system for a mobile-phone
retail shop in Pakistan. It covers the full shop workflow — buying stock,
selling phones (with IMEI tracking) and accessories, customer udhaar
(credit) and installments, repairs, expenses, cash management, and reports —
and it works **offline first**: the shop keeps selling even with no internet,
and everything syncs automatically when the connection returns.

It is built for **non-technical shopkeepers**: large touch-friendly buttons,
fast POS (bill screen responds in under 1 second), and simple Urdu/English
switching.

## 2. Who uses it

| Role | What they can do |
|---|---|
| **Owner / Admin** | Everything: sales, purchases, stock, reports, settings, profit visibility, user management |
| **Manager** | Sales, purchases, stock, reports (can see profit but cannot edit cost/profit settings) |
| **Cashier** | Create bills only. Cost price is hidden from cashiers |

Every action is written to an **audit log** (who did what, and when).

## 3. Tech stack

| Layer | Technology | Why |
|---|---|---|
| Mobile app | **Flutter (Dart)** — Android | One codebase, fast, works offline, camera/barcode scanning |
| Web / desktop admin | **Flutter Web** (same codebase, responsive) | Same code as the app, no second frontend to maintain |
| Backend API | **Node.js + Express (TypeScript)** | Fast, simple, huge ecosystem; runs anywhere |
| Database (server) | **PostgreSQL 16** | Reliable, correct money math (`NUMERIC`), strong constraints |
| Database (device) | **SQLite** (via `sqflite`/`drift`) | Offline-first local store on every phone/tablet |
| Auth | **JWT** (access + refresh tokens), bcrypt password hashing | Stateless, secure, role-based |
| Sync | Outbox pattern + REST sync endpoints | Offline writes queue locally, sync when online |
| Printing | Thermal printer (58mm/80mm, Bluetooth/USB) + A4 PDF invoice | ESC/POS via `esc_pos_utils` / `bluetooth_print` |
| PDF / Excel | `pdf` + `excel` (Dart), server-side export | Invoices, reports |
| Messaging | WhatsApp share (invoice link/PDF), SMS gateway (installment reminders) | Standard in Pakistan |
| Backup | Local backup file + Google Drive / cloud | Restore any time |

> **Note on the stack:** the backend is written in **Node.js + Express +
> TypeScript** (the primary choice). The same API design works with Django
> REST if the shop later prefers Python — the endpoints, database schema and
> business rules do not change.

## 4. System architecture

```
                    ┌─────────────────────────────────┐
                    │   SHOP DEVICES (offline-first)  │
                    │  Flutter app — Android phone /  │
                    │  tablet / desktop (Flutter Web) │
                    │                                 │
                    │  ┌──────────┐  ┌──────────────┐ │
                    │  │ UI (POS, │  │ Local SQLite │ │
                    │  │ Stock,   │◄─┤ DB + Outbox  │ │
                    │  │ Ledger,  │  │ (queued ops) │ │
                    │  │ Reports) │  └──────┬───────┘ │
                    │  └──────────┘         │ sync   │
                    └───────────────────────┼─────────┘
                                            │ HTTPS / REST + JWT
                                            ▼
                    ┌─────────────────────────────────┐
                    │   BACKEND — Node.js + Express   │
                    │  Auth (JWT) · Roles · Validation│
                    │  Sales · Purchases · Stock ·    │
                    │  Ledger · Repairs · Expenses ·  │
                    │  Reports · Audit logs · Sync    │
                    └──────────────┬──────────────────┘
                                   │ SQL
                                   ▼
                    ┌─────────────────────────────────┐
                    │   PostgreSQL 16 (server)        │
                    │  users, products, imei_items,   │
                    │  sales, purchases, ledger,      │
                    │  installments, repairs,         │
                    │  expenses, cash_register,       │
                    │  audit_logs, settings           │
                    └─────────────────────────────────┘

  Peripherals:  Bluetooth/USB thermal printer (58/80mm) · Barcode/QR camera scan
  Messaging:    WhatsApp share · SMS gateway (reminders)
  Backup:       Local file export · Google Drive / cloud
```

### How offline-first works (summary)

1. **Every write goes to local SQLite first.** The bill is saved and printed
   immediately — no waiting for the internet.
2. The same write is also put in a local **outbox queue** (a table of pending
   operations).
3. When the device is online, a background sync job sends the outbox to the
   server in order, and pulls down any changes from the server (new stock,
   price changes, other branches' sales).
4. **Conflicts** (same record changed on two devices) are resolved by
   "server wins for master data, append-only for money": sales, payments and
   ledger entries are never overwritten — they are only appended — so money
   can never be lost or double-counted. Full sync logic is in Module 7.

### Money rules (enforced everywhere)

- All money is stored as **whole PKR** (integer rupees, no paisa decimals).
- `Profit = sale price − purchase cost`, calculated per item.
- A sold IMEI can **never** be sold again unless the sale is returned.
- Sale price below the product's **minimum price** needs admin approval.
- Stock is auto-deducted on sale, auto-added on purchase/return.

## 5. Modules (deliverables 3–9 build these)

| # | Module | Contents |
|---|---|---|
| A | Inventory | Mobiles (brand/model/color/storage/RAM/condition/PTA/IMEI), accessories (quantity stock, barcode, variants), low-stock alerts, Excel/CSV import-export |
| B | Sales / Billing (POS) | Fast bill, scan/search, discount (Rs or %), tax (optional), Cash/JazzCash/Easypaisa/Bank/Card/Partial/Udhaar, customer (name/phone/CNIC), thermal + A4 PDF invoice, WhatsApp share, returns/exchange, hold/resume bill |
| C | Purchases & Suppliers | Purchase entry (supplier invoice, IMEI list, cost), supplier ledger/payables, purchase returns |
| D | Customer Ledger & Installments | Udhaar ledger + running balance, installment plans (down payment, due dates, reminders), overdue list |
| E | Repair & Services | Job card (customer/device/IMEI/fault/cost/advance/status/parts), EasyLoad/recharge with commission |
| F | Expenses & Cash | Daily expenses by category, opening/closing cash, day-end summary, staff salary/advance |
| G | Reports & Dashboard | Daily/weekly/monthly sales, P&L, stock valuation, brand/model sales, best sellers, dead stock, pending udhaar, supplier payables, IMEI history, PDF/Excel export, charts |
| H | Settings | Shop info/logo, invoice template, tax, printer, backup/restore, multi-branch (optional), dark/light mode, language switch |

## 6. Complete folder structure

```
mobile-shop-billing-system/
├── README.md                      # This file — overview & architecture (Module 1)
├── docs/
│   ├── architecture.md            # Detailed architecture (Module 1)
│   ├── api.md                     # API reference (Module 4)
│   ├── database.md                # ER diagram & schema notes (Module 3)
│   ├── sync.md                    # Offline sync design (Module 7)
│   ├── deployment.md              # Setup, build & deploy (Module 8)
│   └── testing.md                 # Seed data & testing guide (Module 9)
├── database/
│   ├── schema.sql                 # Full PostgreSQL schema (Module 3)
│   ├── seed.sql                   # Sample seed data (Module 9)
│   └── migrations/                # Versioned migrations
├── backend/                       # Node.js + Express + TypeScript (Module 4)
│   ├── src/
│   │   ├── config/                # env, database, constants
│   │   ├── middleware/            # auth (JWT), roles, validation, errors, audit
│   │   ├── modules/
│   │   │   ├── auth/              # login, refresh, users, roles
│   │   │   ├── products/          # products, variants, IMEI items, categories, brands
│   │   │   ├── sales/             # bills, sale items, returns, hold/resume
│   │   │   ├── purchases/         # purchases, suppliers, payables, returns
│   │   │   ├── customers/         # customers, ledger, installments
│   │   │   ├── repairs/           # repair job cards, parts
│   │   │   ├── expenses/          # expenses, cash register, salaries
│   │   │   ├── reports/           # dashboard, P&L, stock valuation, IMEI history
│   │   │   ├── settings/          # shop profile, invoice template, tax, printer
│   │   │   └── sync/              # outbox processing, conflict handling
│   │   ├── utils/                 # money math, validation, logging
│   │   └── app.ts                 # Express app wiring
│   ├── tests/                     # unit + API tests (billing logic, Module 9)
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
├── mobile_app/                    # Flutter app — Android + Web (Module 5)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                  # config, theme, localisation (en/ur), router
│   │   ├── data/                  # local SQLite (drift), sync client, API client
│   │   ├── features/
│   │   │   ├── auth/              # login, session
│   │   │   ├── dashboard/         # home, charts
│   │   │   ├── pos/               # billing screen, cart, hold/resume, receipt
│   │   │   ├── inventory/         # products, IMEI, accessories, import/export
│   │   │   ├── customers/         # customers, ledger, installments
│   │   │   ├── purchases/         # purchases, suppliers
│   │   │   ├── repairs/           # job cards
│   │   │   ├── expenses/          # expenses, cash register
│   │   │   ├── reports/           # reports & charts
│   │   │   └── settings/          # shop profile, printer, backup, language
│   │   └── shared/                # widgets, money formatting, printers, PDF
│   ├── assets/
│   │   ├── lang/                  # en.json, ur.json
│   │   └── logo.png
│   ├── pubspec.yaml
│   └── test/                      # widget + unit tests
└── admin_panel/                   # Flutter Web build target (same lib/ as mobile_app)
    └── README.md                  # "Build with: flutter build web" (Module 8)
```

## 7. Delivery order

| Module | Deliverable | Status |
|---|---|---|
| 1 | Project overview & system architecture | ✅ Done |
| 2 | Complete folder structure | ✅ Done |
| 3 | Database schema (SQL) | ✅ **Done — `database/schema.sql` + `docs/database.md`** |
| 4 | Backend API — endpoints + full code | ✅ Done — 113 API routes + 1 health = 114, `docs/api.md` |
| 5 | Mobile app screens — full Flutter code | ✅ Done — POS, inventory, customers, purchases, repairs, expenses, reports, settings, command palette, AI assistant |
| 6 | Thermal printer + PDF invoice | ✅ Done — thermal 58/80mm + A4 PDF + WhatsApp share + QR warranty |
| 7 | Offline sync logic | ✅ Done — outbox push/pull, idempotent `clientUuid`, no double-apply (sales only; see DECISIONS.md) |
| 8 | Setup, build & deployment instructions | ✅ Done — see §8 below |
| 9 | Sample seed data & testing guide | ✅ Done — `database/seed.sql` + `docs/testing.md` |

Round 3 (2026-11-16) verified the whole flow end to end against live
PostgreSQL: purchase → partial sale → invoice → return → ledger → reports
(31/31 checks) plus 42 edge-case checks, `flutter analyze` 0 issues,
`flutter test` 49/49, backend lint + `npm test` 34/34.

---

## 8. Setup, build, run & deploy

### Prerequisites

- **Node.js 18+** (backend; verified on Node 24) + npm
- **PostgreSQL 16** (server database)
- **Flutter SDK 3.24+ / Dart 3.5+** (verified on Flutter 3.35.7, stable).
  If `flutter` is not on your PATH, use the full path, e.g.
  `~/flutter_sdk/flutter/bin/flutter`.
- **Linux only, for `flutter test`:** the Drift/SQLite tests load the system
  SQLite library. If tests fail with
  `Failed to load dynamic library 'libsqlite3.so'`, install the dev package
  (`sudo apt-get install libsqlite3-dev`) or link the runtime library:
  `sudo ln -s /lib/x86_64-linux-gnu/libsqlite3.so.0 /usr/lib/x86_64-linux-gnu/libsqlite3.so`.

### Backend — setup & run

```bash
cd backend
cp .env.example .env        # then edit: DATABASE_URL, JWT_ACCESS_SECRET,
                            # JWT_REFRESH_SECRET, PORT (default 3000)
npm install
npm run dev                 # dev server with live reload (tsx watch)
# Production:
npm run build               # tsc -> dist/
npm start                   # node dist/server.js
```

Health check: `curl http://localhost:3000/health` → `{"ok":true,...}`.

### Database — create & seed

```bash
# As the postgres superuser (adjust for your install):
sudo -u postgres psql -c "CREATE DATABASE shopdb OWNER shopapp;"
# As the app user (password from backend/.env):
psql -h localhost -U shopapp -d shopdb -f database/schema.sql
psql -h localhost -U shopapp -d shopdb -f database/migrations/001_accessories_catalog.sql
psql -h localhost -U shopapp -d shopdb -f database/seed.sql
```

Seed contents (clean install): 3 users, 21 products, 5 sales, 3 purchases,
1,726 catalog items, 30 IMEI items, 26 variants, 10 customers, 2 suppliers.
Stop the backend before dropping/recreating the database (its connection
pool holds the database open and `DROP DATABASE` will fail).

### Default login (seed data) — CHANGE AFTER FIRST LOGIN

| User | Phone | Password | Role |
|---|---|---|---|
| Anas Zaheer (owner/admin) | `+923299966771` | `admin123` | owner |
| Naeem Ahmad | `+923024988560` | `manager123` | manager |
| Bilal Ahmed | `+923001234567` | `cashier123` | cashier |

**These are seed/demo passwords. Change the admin password immediately
after the first login** (Settings → Change Password) and use long random
JWT secrets in production `.env` — never ship the seed secrets.

Login is `POST /api/v1/login` with `{ "phone", "password" }`. Logins are
rate-limited to 5 attempts per 15 minutes per IP by default; for local
verification runs only, raise it with `LOGIN_RATE_LIMIT_MAX=200`.

### Flutter app — run & test

```bash
cd mobile_app
flutter pub get
flutter analyze             # must report 0 errors (0 issues after Round 3)
flutter test                # 49 tests: catalog, HUD, widget smoke, repo E2E
flutter run                 # Android device/emulator, or:
flutter run -d windows      # Windows desktop
flutter run -d chrome       # Web admin
```

### Deploy

- **Backend:** copy `backend/` to the server, set production `.env`
  (real `DATABASE_URL`, fresh JWT secrets, `NODE_ENV=production`),
  `npm install --omit=dev && npm run build && npm start` (or run under
  systemd/pm2 on port 3000 behind a reverse proxy).
- **Android / Windows:** see §9 below.
- **Backups:** back up PostgreSQL regularly (`pg_dump shopdb`) and keep the
  seed + migration files under version control; the app's local SQLite is
  per-device and syncs to the server.

## 9. Download & install (APK + Windows)

The user gets **installable builds, not just source code**.

### Android (phone/tablet)
1. Build: `cd mobile_app && flutter build apk --release`
2. File: `mobile_app/build/app/outputs/flutter-apk/app-release.apk`
3. Install: copy the APK to the phone, tap it, allow "Install unknown
   apps" once when asked, then install. App name: **Baba Farid Mobiles**
   (`com.faan.baba_farid_mobiles`).

### Windows (PC/laptop)
1. Build: `cd mobile_app && flutter build windows --release`
2. Folder: `mobile_app/build/windows/x64/runner/Release/` — contains
   `baba_farid_mobiles.exe` plus its DLL files.
3. Install: zip that whole `Release` folder, copy it to the PC,
   extract it, and double-click `baba_farid_mobiles.exe`. No installer
   is needed (portable). A proper MSIX/Inno Setup installer needs
   Windows-only tooling, so the portable folder is the deliverable.

> The exact APK/Windows file paths and sizes are reported in the final
> build report once the app is complete and both release builds pass.
> The app is configured for both targets from the start (android/ +
> windows/ platform folders, same codebase, same features).
