# Decisions — defaults chosen where the spec left a choice

> Rule: if unclear, choose the most sensible default, note it here, keep
> going. Do not ask the user. Only stop if truly blocked.

## Stack & architecture
1. **State management: flutter_riverpod.** Modern, testable, works with
   go_router. (Provider was considered; Riverpod scales better.)
2. **Navigation: go_router.** Declarative routes, deep-link ready.
3. **Local DB: drift + sqlite3.** Per README. Tables mirror
   database/schema.sql (same names/columns where practical) so sync is
   a straight mapping.
4. **API client: Dio** with JWT interceptor (access token + refresh).
   Base URL from config; default `http://localhost:3000/api/v1`.
5. **Backend port: 3000.** API under `/api/v1`, envelope
   `{ ok, data, error }` (per architecture.md).

## Auth, roles, security
6. **Default admin (seed data): username `admin`, password `admin123`,
   role Owner.** Must be changed after first login (settings prompts
   for it). Documented in README.md. Demo users: manager `manager` /
   `manager123`, cashier `cashier` / `cashier123`.
7. **Passwords: bcrypt cost 12.** JWT access 15 min, refresh 7 days
   (revocable). Login rate limit: 5 failed attempts → 15 min lockout.
8. **2FA (owner): TOTP** via `otp` package; setup shows a QR + secret,
   login asks for the 6-digit code after password. Optional per user.
9. **Local DB encryption: AES-256** via SQLCipher-compatible encrypted
   sqlite where supported; on platforms without it, the DB file is
   encrypted at rest with a key in flutter_secure_storage. Documented
   as a best-effort platform limitation.
10. **Audit log: hash-chained.** Each audit row stores
    `prev_hash` + `hash` (SHA-256 of prev_hash + payload), so tampering
    is detectable. Viewer in Settings → Audit Log.
11. **Privacy mode:** a toggle that hides/blurs all money amounts
    (shows `****`). Auto-lock after 2 minutes inactivity (configurable).

## Business rules (enforced in code, not just UI)
12. **Sold IMEI can never be sold again** unless its sale is returned
    (status returns to AVAILABLE). Enforced in the sale transaction
    (checks IMEI status = AVAILABLE) and by the partial unique index
    in schema.sql.
13. **Below-minimum-price sale needs admin approval:** the POS sends
    `admin_approved_by` (admin PIN/username); without it the sale is
    rejected. UI shows a clear warning.
14. **Money is whole PKR integers everywhere.** No paisa decimals.
    Rounding only at display. Profit = sale − purchase cost per item,
    stored on sale_items.
15. **Stock auto-deduct on sale, auto-add on purchase/return.** All in
    one DB transaction (sale + items + IMEI status + stock + ledger +
    cash + audit) — all or nothing.

## POS, printing, messaging
16. **Thermal printing: ESC/POS** via `esc_pos_utils_plus` (58mm/80mm),
    Bluetooth/USB. If no printer is connected, the app falls back to
    PDF + on-screen receipt. A4 PDF invoice via `pdf` + `printing`.
17. **WhatsApp: wa.me share links + share_plus for the PDF.** No
    WhatsApp Business API (no credentials). The invoice PDF is shared
    through the system share sheet / WhatsApp.
18. **SMS reminders: pluggable gateway interface** (`SmsGateway`) with
    a safe default that opens the SMS app with a prefilled message.
    A real gateway (e.g. Twilio/Jazz) can be plugged in later with
    credentials. Recorded as a known limitation.
19. **QR warranty:** each invoice gets a QR code encoding
    `https://baba-farid-mobiles.example/verify?invoice=<no>&imei=<imei>`
    (verification page is a local in-app screen + a printable warranty
    card). No public hosted verification site exists yet — the QR opens
    the in-app IMEI-history lookup. Recorded as a limitation.

## AI assistant & smart features
20. **AI assistant is a LOCAL rule-based query layer** (no external AI
    API, no key, works offline). It parses natural-language questions
    (English + Roman Urdu) into structured queries against the shop's
    own data (e.g. "aaj ka profit kitna hai?" → today's P&L;
    "kaun se mobiles 60 din se unsold hain?" → dead-stock query).
    Keyword + pattern matching, not a remote LLM.
21. **Smart pricing suggestions:** based on stock age, purchase cost,
    and competitor price entries (a `competitor_prices` input in
    product settings). Suggests a price band; never auto-changes a price.
22. **Sales forecasting:** simple moving-average + trend on the last
    90 days of sales. Clearly labelled as an estimate.
23. **Loyalty points:** 1 point per Rs 100 spent; 100 points = Rs 100
    discount. Wallet balance and coupon codes are stored per customer.
    Coupons are created in Settings.

## Sync & backup
24. **Sync: outbox pattern.** Every local write queues an outbox row
    with a client UUID. Push sends in order; pull fetches since a
    timestamp. Server-wins for master data, append-only for money.
    If two devices sell the same IMEI offline, the first synced wins;
    the second gets a conflict error and the sale is flagged.
25. **Backup: local file export/import** (JSON + SQLite copy) with
    AES-256 encryption. Google Drive upload is a documented optional
    manual step (no Drive API credentials on this machine).

## UI / theme
26. **Default theme: Hacker** (dark #0A0E14, neon green #00FF9C,
    cyan #00E5FF, magenta #FF2E88). Switcher: Hacker, Matrix Green,
    Cyber Blue, Light Mode. Animations can be turned off in Settings
    (for low-end phones).
27. **Fonts:** JetBrains Mono for numbers/IMEI/amounts; Inter/Roboto
    for body; Noto Nastaliq Urdu for Urdu. If a font is unavailable
    on a device, fall back to the system monospace/sans.
28. **Language:** English default, Urdu toggle with RTL. All user-facing
    strings go through `AppStrings.tr()`.
29. **POS must stay under 1 second.** Lists are cached, search is
    indexed, animations are cheap (no heavy blur on lists).

## Verification environment
30. **Flutter/Dart SDK is now installed** at `~/flutter_sdk/flutter`
    (Flutter 3.35.7, Dart 3.9.2, installed 2026-11-16). The first
    download's extraction failed on file-ownership preservation and
    was fixed with `tar --no-same-owner --no-same-permissions`.
    Verification (`flutter analyze`, `flutter test`, `flutter build`)
    is therefore possible; run it in Round 3. Note: the tool warns
    about running as root — harmless for this build machine.
31. **PostgreSQL is NOT installed on this machine.** schema.sql is
    verified by parsing (balanced SQL, table/column names), not by
    executing it. The README tells the user how to create the DB and
    run the schema + seed.

## Accessories master catalog (M2-Catalog)
32. **Catalog is a separate, versioned seed** (JSON + SQL migration).
    New tables (catalog_*) extend the schema; existing tables are not
    modified. A catalog update (new version) inserts new items and
    updates estimated prices only — it never deletes stock, prices the
    shopkeeper set, or custom items.
33. **All catalog prices are ESTIMATED** (marked estimated in data
    and UI). Pakistan accessory prices change often; the shopkeeper
    confirms the buying price at stock-in. Defaults are sensible
    Punjab-market estimates, never presented as live market rates.
34. **Catalog has its own local DB file (catalog.db)** in the Flutter
    app, separate from the main drift DB, so catalog updates never
    risk the shop's transactional data. Stock-in writes to
    catalog_stock; the main inventory reads it.
35. **Search is fuzzy + Roman Urdu tolerant** (e.g. "type c cabel"
    finds Type-C cable). Normalisation: lowercase, strip spaces and
    hyphens, Roman-Urdu synonym map, token/substring matching, ranked.
36. **Barcode linking is permanent.** First scan of an unknown barcode
    asks which catalog item it is; the link is stored and later scans
    add stock instantly.
37. **Zero-stock items are hidden from POS by default** (toggle to
    show). Low-stock threshold is per-item and editable; the reorder
    list is grouped by supplier.
38. **Catalog JSON is reusable** (database/catalog/accessories_catalog.json)
    so the same catalog can later be loaded into the web software.

## Holographic HUD animation (M6-HUD)
39. **HUD is original code-drawn animation only** (Flutter
    CustomPainter). No copied footage, logos, or movie layouts.
    Dark teal/black background, glowing cyan (#00E5FF) and orange
    (#FF8A00) accents, thin technical lines, rotating rings, particle
    core, scrolling data columns, labeled panels, waveform strip.
40. **HUD widgets are data-driven.** They take real shop values as
    constructor params (sales, stock %, cash, udhaar, alerts, sync).
    DataRain scrolls REAL values (IMEI fragments, bill numbers,
    amounts), never random text. The demo gallery uses clearly-labelled
    illustrative values only.
41. **HUD uses the cyberpunk token values** (same colors as the M6
    theme) via a local hud_theme.dart; it is unified with the shared
    CyberTheme in Round 2. HUD labels may stay English; Urdu text
    stays readable (Noto Nastaliq Urdu) and important numbers keep
    WCAG AA contrast.
42. **Performance is enforced, not hoped for.** Target 60fps; the
    performance manager auto-falls-back to 30fps then a static image
    when frame drops are detected. Particle budget: 600 high-end,
    250 low-end, 0 in off mode. Pre-computed particle positions,
    RepaintBoundary everywhere. Animation pauses while the POS screen
    is active, when the app is backgrounded, or when battery saver
    is on. POS must still respond in under 1 second.
43. **Animation settings keys** (shared_preferences, so the settings
    screen and the HUD agree): `hud_animation_level`
    (full/reduced/off), `hud_battery_saver_auto_off` (bool),
    `hud_video_background` (bool/path). The HUD reads these directly;
    Round 2 settings screen writes the same keys.
44. **Optional video background** is a looped, muted H.264 720p clip
    under 5MB, paused when not visible, selectable in Settings. The
    video_player dependency is added to pubspec.yaml by the foundation
    agent. A render doc explains how to produce the loop (record the
    HUD demo gallery). No video file is bundled by default.

## Backend (Module 4) — as delivered and verified
45. **Refresh tokens are stateless JWTs** (no refresh-token table);
    logout is client-side token discard. This is acceptable for this
    deployment; a refresh-token table can be added later for
    server-side revocation.
46. **bcryptjs (pure JS, cost 12) is used instead of native bcrypt**
    (no build toolchain needed on the server). Password hashing
    strength is the same.
47. **Repair technician is not implemented** (schema has no
    technician column on repairs). Left as is unless the user asks.
48. **Schema bug fixed (2026-11-16):** the `ALTER TABLE payments
    ADD CONSTRAINT fk_pay_repair ... REFERENCES repairs(id)` ran
    before the `repairs` table was created, so a fresh
    `psql -f schema.sql` failed. The FK is now added after the
    repairs table definition.
49. **Accessories catalog is mounted** at `/api/v1/catalog` (12
    endpoints) after migration
    `database/migrations/001_accessories_catalog.sql` is applied.
    The catalog module was written by the catalog agent and verified
    to compile; mounting was done by the coordinator after Module 4
    finished.

## Distribution — installable builds (APK + Windows)
50. **Android APK:** `flutter build apk --release` produces
    `build/app/outputs/flutter-apk/app-release.apk`. The user installs
    it by sideloading on their phone (allow "Install unknown apps"
    once). ApplicationId `com.faan.baba_farid_mobiles`, display name
    "Baba Farid Mobiles". Also build an AAB (`flutter build appbundle`)
    if the shop later wants Google Play.
51. **Windows:** `flutter build windows --release` produces
    `build/windows/x64/runner/Release/` containing
    `baba_farid_mobiles.exe` + its DLLs. This is a portable folder:
    zip it, the user extracts it and runs the .exe (no installer).
    A proper MSIX/Inno Setup installer needs Windows-only tooling
    that is not available on this Linux build machine, so the portable
    folder + clear install steps is the deliverable.
52. **Windows limitation:** `mobile_scanner` (camera barcode scan) is
    mobile-only and has no Windows implementation. On Windows the
    barcode screen must be guarded (or a USB barcode scanner used —
    it types as a keyboard, so it works). If the Windows build fails
    on a mobile-only plugin, guard that import (conditional import)
    in Round 3; do not drop the feature on Android.
53. **Secrets must be generated inside the shell.** Raw passwords
    typed as literals in tool calls get redacted in transit (this
    actually happened: backend/.env ended up with the literal
    `<redacted>` as the DATABASE_URL). Always generate secrets with a
    shell command (e.g. `openssl rand -hex 16`, `node -e
    "require('crypto').randomBytes(64).toString('hex')"`) and write
    them to files via shell variables, never as literals.
54. **PostgreSQL is now installed locally** (16, cluster 16/main,
    port 5432) for verification; the live database used for testing
    is `shopdb` with role `shopapp`. The shop's production DB setup
    (own server/VPS) is documented in docs/deployment.md. The
    backend `.env` is local-only and must never be committed.
55. **Seed ordering rule:** `payments` must be inserted AFTER
    `repairs`/`installments` because payments reference repair_id
    and installment_id. The seed file was fixed accordingly
    (payments block moved after repair_parts). Any future seed rows
    that reference other tables must be ordered the same way.

## Round 1 verification fixes (2026-11-16, coordinator)
56. **Low stock = STRICTLY below the threshold** (`quantity <
    lowStockThreshold`), not `<=`. At exactly the threshold the item
    is at its reorder point but not yet below it. Applied in
    `CatalogItem.isLowStock`, `CatalogRepository.lowStock()` and
    `reorderListBySupplier()`. Default threshold is 5.
57. **Fuzzy search prefix rule:** only match when an ITEM token starts
    with the QUERY token (`t.startsWith(q)` — user typed a partial
    word). Never match `q.startsWith(t)` — that made an exact SKU
    query like `ACC-CAB-ANK-TC10-002` return 5 items (every item
    whose tokens include a short prefix like `acc`/`cab`/`ank`).
58. **Drift table-name collisions (Flutter):**
    - `Outbox.tableName` collided with drift `Table.tableName`.
      Renamed the Dart getter to `entityTable` and kept the SQLite
      column name `table_name` via `.named('table_name')`, so the
      sync payload is unchanged.
    - `AuditLogs`/`SyncLogs` drift data classes (`AuditLog`,
      `SyncLog`) collided with the domain models of the same name.
      `app_database.dart` now imports only `auditHash` from the
      domain model (`show auditHash`); importing the whole domain
      file made drift codegen type the generated `map()` return as
      the domain model.
    - Drift strips a trailing `s` for data-class names, so plural
      tables (`Products` → `Product`) are fine, but singular tables
      (`Staff` → `StaffData`, `Outbox` → `OutboxData`) need the
      `Data` suffix. Repositories must use the DATA class, not the
      table class, for row types.
59. **Flutter 3.35 API updates:** `CardTheme` → `CardThemeData`,
    `DialogTheme` → `DialogThemeData` in `ThemeData`. `StateProvider`
    override uses `overrideWith((ref) => value)`, NOT
    `overrideWithValue` (removed). The `library;` directive must be
    the FIRST line of a Dart file. `Ticker` needs
    `package:flutter/scheduler.dart`.
60. **Encryption package:** `encrypt: ^5.0.3` added to pubspec.yaml
    (the AES-256 helper in `lib/data/storage/encryption.dart` needs
    it; it pulls in pointycastle + crypto).
61. **Drift codegen is a build step:** after changing any drift table,
    run `dart run build_runner build --delete-conflicting-outputs`
    (from mobile_app/) — the `.g.dart` files are generated and
    committed. `flutter analyze` must show 0 errors and `flutter
    test` must pass before a milestone is marked done.
62. **Linux test dependency:** `flutter test` needs the native SQLite
    library — install `libsqlite3-dev` (`apt-get install -y
    libsqlite3-dev`) or drift's in-memory DB fails to load
    (`libsqlite3.so: cannot open shared object file`).
63. **Catalog test quantity fix:** the low-stock test now stocks 6
    (above the default threshold 5) so the item leaves the low-stock
    list; stocking 3 was below threshold, so the old expectation was
    wrong for that quantity. The test's intent (stocking a sufficient
    quantity clears the flag) is unchanged.

## Round 2 gaps (recorded 2026-11-16, fix in Round 3)
64. **Repair expected-delivery date has no column.** The `Repair`
    model has no expected-delivery field, so the form records it at
    the top of the job's `notes` ("Expected delivery: 20 Nov 2026").
    If a real column is wanted, add `expected_delivery_date` to the
    schema + drift table + model (a migration, not a silent rename).
65. **Repair parts do not auto-change the final cost.** Final cost
    starts at the estimate; adding a part records it and deducts
    stock but does not change what the customer pays, since the
    estimate may already include parts. Parts total is shown
    separately; labour charges / "Update Final Cost" adjust the
    payable. This is deliberate, not a bug.
66. **Deliver-with-udhaar does not post to the customer ledger.**
    When a repair is delivered with balance > 0, the balance stays
    visible on the delivered job card, but there is NO repository
    method to post that balance as an udhaar debit to the customer
    ledger — nothing is written to the ledger. Round 3 must add a
    repo method (e.g. `RepairRepository.deliverWithUdhaar` posting a
    ledger debit) or the udhaar will be invisible in the ledger.
67. **`RepairRepository.removePart` does not restore stock.** It
    deletes the part row but the variant stock deducted by `addPart`
    is not added back. Round 3 must restore the quantity in
    `removePart` (same transaction as the delete).
68. **DaySummary has no cash-vs-other-method sales split.**
    `totalSales` covers all payment methods, so the day-end screen
    cannot show cash sales vs JazzCash/bank sales separately. Round 3
    must add the split to `DaySummary` (or compute it from the sales
    list) if the shop wants it.
69. **No `SupplierRepository` exists.** Supplier list/picker is
    sourced from `ReportRepository.supplierPayables()`, so suppliers
    with zero payable do not appear and suppliers cannot be created
    from the UI. Round 3 should add a `SupplierRepository`
    (`listSuppliers`/`getSupplier`/`createSupplier`) with a one-line
    swap in `purchase_helpers.dart`.
70. **Catalog has no `stockOut`.** A catalog accessory return records
    the refund and reduces the payable, but catalog stock cannot be
    decremented on return. Round 3 should add `CatalogRepository.
    stockOut(sku, qty)` and call it from the purchase-return flow.
71. **Installment plans require a sale.** `installments.sale_id` is
    NOT NULL, so a plan can only be created against one of the
    customer's sales; customers with no sales get an explanatory
    state, not a plan. This matches the schema; changing it needs a
    schema migration (nullable sale_id).

## Round 2H findings (recorded 2026-11-16, fix in Round 3)
72. **Auth service is still unwired.** `main.dart` does not override
    `authServiceProvider`, so `authStateProvider` throws and `App`
    treats the user as signed out (via `onError`). Round 3 must wire
    the real `ApiAuthService` (from `lib/data/services/
    api_auth_service.dart`) into `main.dart` via a ProviderScope
    override — until then the app cannot actually log in.
73. **Splash uses imperative navigation, which breaks under
    go_router.** `SplashScreen` calls `Navigator.pushReplacement`,
    which throws ("A page-based route cannot be completed using
    imperative api"). The router works around it by navigating away
    from `/` itself after a grace period (3.0s animations-on, 300ms
    off, timer owned by `App`). The proper fix is for the splash to
    navigate via `context.go`.
74. **Three files define the same repository providers**
    (`dashboard/repository_providers.dart`, `pos/pos_providers.dart`,
    `repairs/repair_common.dart`), so the app currently opens
    multiple `AppDatabase` instances on one file. Round 3 must
    consolidate into ONE shared providers file and have every screen
    + the router use it.
75. **Printed output is English-only.** The `pdf` package's built-in
    fonts are Latin-only, so Urdu labels would print as boxes.
    On-screen invoice/warranty screens are fully bilingual; receipts
    /PDFs use the English strings. Bundling a TTF (e.g. Noto
    Nastaliq Urdu) would enable Urdu printing. (Em-dashes U+2014 do
    not render in the built-in fonts either, so PDF text uses `-`.)
76. **`/pos/returns` was a shim; now wired.** H left it as a
    `ComingSoonScreen` because it checked before D finished, but
    `ReturnScreen` exists (D built it, const constructor). The
    coordinator wired it to the real screen in Round 2 review; no
    shims remain in the router.

## Round 3 verification (recorded 2026-11-16, Worker V)
77. **Sync adapter design + non-sale outbox limitation.**
    `SyncEngine.push()` sends only outbox rows of type `sales`/`insert`,
    converted by `_saleToSyncPayload` into the server's `/sync/push` sale
    shape; every other outbox row (products, customers, purchases, ...)
    stays pending forever. The server applies each sale idempotently by
    `clientUuid` (re-push returns `skipped: already_synced`, never a
    duplicate bill — verified live). Pull (`/sync/pull`, server wins) is
    implemented but was not exercised live in Round 3. A future round must
    add push adapters for the non-sale outbox types or stop queueing them.
78. **Endpoint count, verified by grep.** 113 API route registrations
    across `backend/src/modules/*/routes.ts` (Auth 10, Products 19,
    Sales 11, Purchases & Suppliers 10, Customers & Installments 11,
    Repairs & Service Sales 9, Expenses/Staff/Salaries/Cash 16,
    Reports 10, Settings 2, Sync 3, Catalog 12) + 1 health check
    (`GET /health` in `app.ts`) = **114 mounted routes**. `docs/api.md`
    already stated 114 and is correct.
79. **`api.test.ts` signs with `env.jwtAccessSecret`.** The two API tests
    that failed at the Round 3 baseline used a hardcoded dev secret; they
    now sign tokens with the configured `env.jwtAccessSecret`, so the
    suite passes (34/34) against any `.env`. Never hardcode a JWT secret
    in a test again.
80. **Supplier picker fix (Round 3).** `loadSupplierSummaries` used to
    source suppliers only from `ReportRepository.supplierPayables`, so
    zero-payable suppliers were invisible in pickers and in the supplier
    detail route (false "not found"). It now takes a required
    `SupplierRepository` (`supplierRepositoryProvider`) and lists all
    suppliers; the legacy payable-only branch and the unused
    `suppliersOnlyPayableNote` string (EN + UR) were deleted.
    `app_router.dart` `_SupplierDetailRoute` now loads via
    `SupplierRepository.getSupplier` and shows not-found only when the
    supplier truly does not exist.
81. **E2E results (live, clean seed, PostgreSQL 16).** `scripts/e2e-live.mjs`
    31/31 pass: purchase 2 phones + 5 accessories (grand_total 104000,
    supplier payable 244500→348500) → partial sale of 1 phone (54000,
    paid 30000, due 24000, IMEI sold) → invoice 200 → return phone (sale
    `returned`, totals 0, IMEI available, ledger 0) → dashboard + P&L
    unchanged by the returned sale. `scripts/edge-cases-live.mjs` 42/42
    pass: duplicate IMEI 409, accessory return restores stock, partial
    payment then full payoff, overdue installments flagged, sync
    double-push skipped, cashier sees no cost prices, below-min-price
    403 without / 201 with admin approval. Dart `test/e2e_test.dart`
    (in-memory drift) also passes: purchase → partial sale → return →
    purchase return → repair → reports.
82. **Ledger balances are SUM-based, not latest-row.** Same-millisecond
    ledger entries made "latest row wins" wrong (e.g. seed supplier
    entries PUR-003 purchase + payment on the same timestamp). Backend
    `appendLedger` and every balance read (customers, suppliers,
    purchases, reports) and the Flutter repositories now compute
    `SUM(debit − credit)` (customers) / `SUM(credit − debit)`
    (suppliers). Opening entries are ledger rows, so they are included;
    the opening balance/payable is only a fallback when zero rows exist.
83. **Returns reverse money, not just stock.** Backend `returnSale` now
    reduces `grand_total` by the refund and `sale_items.profit` pro-rata,
    so returned bills contribute 0 revenue/profit to dashboard/P&L; the
    customer ledger is credited only with the refund-from-balance part
    (`refund − min(refund, paid)`), and double-returns are rejected.
    Flutter `returnSale` mirrors this (ledger credit, double-return
    guard, profit reduction). `docs/api.md` §Returns documents it.
84. **Overdue installments are flipped, not just listed.**
    `GET /installments/overdue` first flips past-due `pending`/`partial`
    installments to status `overdue`, then lists `overdue` rows (backend
    + Flutter mirror); the dashboard overdue query includes `overdue`.
    Before this fix the seed's overdue row (due 2026-11-15) was invisible.
85. **Reports net out returns.** Flutter `profitAndLoss` COGS subtracts
    returned qty; `brandSales`/`bestSellers` and backend
    `brandModelSales`/`bestSellers` net `total − refunded` and
    `qty − returned_qty`. Backend `brandModelSales.units_sold` is now
    `SUM(quantity − returned)` (units) instead of `COUNT(*)` (lines).
86. **Lint: 160 issues → 0.** `dart fix --apply` cleared 93 mechanical
    fixes (38 files), then 63 `withOpacity` calls were converted to
    `withValues(alpha: …)` by script and the dead `_payment` mapper was
    removed; final `flutter analyze` reports **No issues found** and
    `flutter test` is 49/49. `dart fix` destroyed two hand-written
    defaults it could not see: `_CutCornerClipper.cut` in
    `cyber_widgets.dart` and `hud_panel.dart` was restored as
    `final double cut = 12;` — **12 is a best guess, not the original
    value** (no git history); verify visually if the card corners look
    wrong. `dart fix` also broke two `errorBuilder` closures that shadowed
    an outer `c` (colors) variable; the closure parameter was renamed to
    `_` in `login_screen.dart` and `splash_screen.dart`.
87. **`npm audit` cannot run in this sandbox.** The registry's audit
    endpoint returns 403 `policy_denied`, so `npm audit` / `npm audit fix`
    could not be run or applied. Run it on a machine with registry access
    before deploying; dependencies are pinned in `package-lock.json`.
    (Backend lint is `tsc --noEmit`, clean; `npm test` 34/34.)
88. **VM replacement wipes system-level prerequisites.** During Round 3
    the VM was replaced: PostgreSQL 16 and the `libsqlite3.so` dev symlink
    vanished (only `libsqlite3.so.0` remained), which killed the backend
    and broke every Drift test with `Failed to load dynamic library
    'libsqlite3.so'`. Fix: reinstall PostgreSQL 16 + seed, and
    `sudo apt-get install libsqlite3-dev` (or re-create the symlink).
    `README.md` §8 documents both. Anything outside `~` must be treated
    as ephemeral.
