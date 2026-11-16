# Build Plan — Baba Farid Mobiles Billing & Inventory System

> Coordinator plan. Shop: Baba Farid Mobiles, Jamal Chowk, Depalpur Road,
> Pakpattan. Currency PKR. Roles: Owner/Admin, Manager, Cashier.
> Stack: Flutter (Android + Web) + Node.js/Express/TypeScript + PostgreSQL 16
> + SQLite (drift) on device. Offline-first, JWT + bcrypt, audit trail.

## Current state (verified 2026-11-16)
- Modules 1–3 DONE: README.md, docs/architecture.md, database/schema.sql
  (33 tables, 14 enums, 44 indexes), docs/database.md.
- Module 4 (Backend API) DONE + VERIFIED (2026-11-16): 102 mounted
  routes (101 API + health), all modules, business rules enforced,
  tsc clean, build clean, vitest 34/34 pass, docs/api.md complete.
  Backend is now open for coordinator work.
- Schema bug FIXED (2026-11-16, user-approved): fk_pay_repair moved
  to after the repairs table; verified zero forward references in
  schema.sql. Catalog module MOUNTED at /api/v1/catalog (12
  endpoints) after migration 001_accessories_catalog.sql; verified
  4/4 route checks return 401 (mounted + auth guard live) and
  backend lint/build/tests still pass.
- Flutter/Dart SDK installed (3.35.7 / 3.9.2). pubspec fixed
  (flutter_lints ^4.0.0, intl ^0.20.2); `flutter pub get` resolves
  (162 dependencies). Android + Windows platforms added
  (`flutter create --platforms=android,windows`, org com.faan);
  applicationId com.faan.baba_farid_mobiles; display name
  "Baba Farid Mobiles" (Android label + Windows title). lib/ untouched.
- PostgreSQL 16 INSTALLED + RUNNING (2026-11-16). Live verification
  DONE: fresh `psql -f schema.sql` loads cleanly, catalog migration
  loads (1,726 items), fixed seed.sql loads (3 users, 21 products,
  30 IMEI, 5 sales, 10 customers). Live API smoke test passed:
  server connects, admin login works (JWT), catalog list returns
  1,726 items, sales list returns seeded bills. Seed bug fixed:
  payments block moved after repairs (it references repair_id).
  Backend `.env` is local-only (not committed); secrets must be
  generated inside the shell, never typed as literals (redaction).
- Web artifact "mobile-billing-and-stock-software" is a SEPARATE product.
  Do NOT touch it. This project's deliverable is source code in this folder.
- Flutter/Dart SDK is NOT installed on this machine. Attempting a
  background install for verification; if unavailable, verify via Dart SDK
  (pure logic) + backend tests + careful review, and record it as a
  limitation in the final report.
- Logo files (use in the Flutter app):
  mobile_app/assets/baba-farid-mobiles-logo.png and
  mobile_app/assets/baba-farid-mobiles-logo-digital.png.

## Milestones (a usable product must exist after each; never leave it broken)
| # | Milestone | Goal | Status |
|---|-----------|------|--------|
| M1 | Setup, schema, auth & roles | Project setup, folder structure, DB schema, auth/roles | Mostly done (Mod 1–3); verify + seed data |
| M2 | Inventory + POS | IMEI tracking, accessories, fast billing end-to-end | Pending |
| M2-Catalog | Accessories Master Catalog | 1500+ pre-loaded accessories, quick stock-in, bulk, barcode, opening stock | In progress (Round 1b) |
| M3 | Ledger, udhaar, installments, suppliers, purchases | Customer ledger, installments, supplier ledger, purchases | Pending |
| M4 | Printing, WhatsApp, QR warranty | Thermal 58/80mm + PDF invoice, WhatsApp share, QR warranty | Pending |
| M5 | Repairs, expenses, cash, reports, dashboard | Job cards, expenses, cash register, reports, dashboard | Pending |
| M6 | Cyberpunk theme, splash/login, command palette | Hacker theme, boot splash, terminal login, command palette | Pending |
| M6-HUD | Holographic HUD animation | Original code-drawn HUD widgets, dashboard hero, lock screen, performance fallback | In progress (Round 1c) |
| M7 | Security, offline sync, backup/restore | Biometric/PIN, AES-256 local DB, 2FA, hash-chained audit, sync, backup | Pending |
| M8 | AI assistant, smart alerts, polish | NL questions from shop data, pricing suggestions, restock alerts, loyalty | Pending |
| DIST | Installable builds (APK + Windows) | Release APK + Windows release folder/exe, with install steps | Configured (platforms added); builds in Round 3 |

## Subagent rounds (file ownership — no two agents write the same file)
### Round 1 (parallel, now)
- **A — Flutter foundation + theme + splash/login + l10n.**
  Owns: mobile_app/pubspec.yaml, lib/main.dart, lib/app.dart,
  lib/core/** (theme, l10n, config, constants), lib/features/auth/**.
  Must NOT write lib/data/**, lib/domain/**, or other feature screens.
- **B — Flutter data + domain layer.**
  Owns: lib/domain/** (models, money, bill math, IMEI rules, validation),
  lib/data/** (drift DB, DAOs, repositories, API client, sync engine,
  local storage). Must NOT write pubspec.yaml or main.dart.
  Must define clear repository interfaces (see Contracts below) that
  screens will use.
- **C — Seed data + docs.**
  Owns: database/seed.sql, docs/testing.md, docs/sync.md,
  docs/deployment.md, admin_panel/README.md. Must read schema.sql and
  match table/column names exactly. Must NOT touch backend/ or mobile_app/.

### Round 1b (parallel with Round 1 — Accessories Master Catalog)
- **Cat-1 — Catalog data.** Owns: scripts/generate_catalog.py,
  database/catalog/accessories_catalog.json,
  database/migrations/001_accessories_catalog.sql, docs/catalog.md,
  backend/src/modules/catalog/* (NEW files only — do NOT touch app.ts
  or existing modules), mobile_app/lib/data/database/catalog_tables.dart,
  mobile_app/lib/data/database/catalog_database.dart,
  mobile_app/lib/features/catalog/catalog_models.dart,
  mobile_app/lib/features/catalog/catalog_repository.dart,
  mobile_app/lib/features/catalog/catalog_search.dart,
  mobile_app/test/catalog_test.dart.
- **Cat-2 — Catalog screens.** Owns ONLY
  mobile_app/lib/features/catalog/screens/*. Uses the CatalogRepository
  interface (defined in Cat-1's brief). Cyberpunk styling via a local
  CatalogTheme helper (swap to shared CyberTheme in Round 2).
- Catalog extends the schema (new tables) — it does NOT modify
  schema.sql or existing tables, and does NOT touch the in-flight
  Module 4 backend work.

### Round 1c (parallel with Round 1 — Holographic HUD animation)
- **HUD — HUD animation system.** Owns ONLY
  mobile_app/lib/features/hud/** (widgets, painters, demo gallery,
  performance manager, video background) + mobile_app/test/hud_test.dart
  + docs/hud_video_render.md. Original code-drawn animation only (no
  copied footage/logos/layouts). Uses the cyberpunk token values
  (same colors as the M6 theme) via a local hud_theme.dart — unify
  with the shared CyberTheme in Round 2. Delivers data-driven widgets
  (they take real values as constructor params); Round 2 wires them
  into the splash, dashboard, lock screen, and settings. Must NOT
  touch lib/features/auth/** (splash/login owned by A),
  lib/features/dashboard/**, lib/features/settings/**, or pubspec.yaml
  (video_player dependency is being added by A).

### Round 2 (after Round 1 — screens, built on Round 1 contracts)
- **D — POS + Inventory screens.** Owns lib/features/pos/**,
  lib/features/inventory/**.
- **E — Customers/Ledger/Installments + Purchases/Suppliers screens.**
  Owns lib/features/customers/**, lib/features/purchases/**.
- **F — Repairs + Expenses + Cash screens.** Owns lib/features/repairs/**,
  lib/features/expenses/**.
- **G — Dashboard + Reports + Settings screens.** Owns
  lib/features/dashboard/**, lib/features/reports/**,
  lib/features/settings/**.
- **H — Smart features + router.** Owns lib/features/command_palette/**,
  lib/features/ai/**, lib/shared/printing/**, lib/shared/qr/**,
  lib/shared/messaging/**, lib/core/router.dart (wires all screens).

### Round 3 (verification — after Round 2 and after Module 4 backend finishes)
- **I — Verification.** Runs tsc + backend tests + (if Flutter SDK
  available) flutter analyze/build/test. Runs the end-to-end scenario.
  Runs lint + dependency security scan. Ticks CHECKLIST.md, updates
  README.md, removes dead code/logs. Owns: backend/tests/** (only if the
  Module 4 agent did not write them), docs/testing.md updates, README.md.

## Contracts (so parallel agents agree)
- **Money:** all money is integer whole PKR. `Money` helpers in
  lib/domain/money.dart: `roundPkr`, `formatPkr`, `profitPerItem`.
- **Repository interfaces** (defined by B in lib/data/repositories/):
  `ProductRepository`, `SaleRepository`, `CustomerRepository`,
  `PurchaseRepository`, `RepairRepository`, `ExpenseRepository`,
  `ReportRepository`, `SettingsRepository`. Each exposes async methods
  returning domain models; screens use these, never drift directly.
- **API client** (B): `ApiClient` (Dio + JWT, base URL from config),
  `AuthService` (login/refresh/logout, token in secure storage).
- **Theme** (A): `CyberTheme` with 4 themes (hacker, matrix, cyberBlue,
  light), `CyberColors`, `CyberTextStyles`, `CyberWidgets` (button, card,
  text field, table, dialog, badge, stat card, chart, toggle, app bar,
  search bar). All screens use these widgets.
- **l10n** (A): `AppStrings` with `en` and `ur` maps; `tr(key)` lookup;
  Urdu uses Noto Nastaliq Urdu and RTL.
- **Sync** (B): outbox table + `SyncEngine.push()` / `SyncEngine.pull()`;
  server-wins for master data, append-only for money records.

## Dependencies (pubspec.yaml — owned by A; B/C must not duplicate)
flutter, flutter_localizations, intl, flutter_riverpod, go_router,
drift, drift_sqflite (or sqlite3_flutter_libs), dio,
shared_preferences, flutter_secure_storage, local_auth,
mobile_scanner, qr_flutter, pdf, printing, esc_pos_utils_plus,
share_plus, url_launcher, path_provider, intl, otp, crypto,
fl_chart (or custom charts), file_picker, csv, excel.

## Verification (after each milestone)
- Backend: `npm install && npx tsc --noEmit` (must pass), `npm test`
  (unit + API tests must pass).
- Flutter (if SDK installs): `flutter analyze` (0 errors),
  `flutter test` (unit + widget tests pass), `flutter build apk --debug`.
- Edge cases to test: duplicate IMEI rejected; sale return restores IMEI
  + stock + ledger; partial payment leaves correct balance; installment
  overdue flagged; offline sale then sync (no double-apply); cashier
  cannot see cost prices; below-min-price sale needs admin approval.
- End-to-end: purchase phones → sell with partial payment → print
  invoice → return item → check ledger → check reports. Fix all bugs.
- Lint + dependency security scan (`npm audit`); fix issues.

## Risks / limitations
- Flutter SDK may not install on this machine → UI build cannot be
  verified locally; record as a limitation, verify logic via Dart SDK
  if possible and review code carefully.
- Module 4 backend agent is still writing; backend/ is off-limits until
  it reports completion. Backend tests depend on it.
- No real WhatsApp Business API / SMS gateway credentials → WhatsApp
  uses wa.me share links, SMS uses a pluggable gateway interface with a
  safe default (open SMS app / log). Recorded in DECISIONS.md.
- No Google Drive API credentials → backup/restore uses local file
  export/import; Drive upload is a documented optional step.
