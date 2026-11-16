# Admin Panel — Baba Farid Mobiles Billing & Inventory System

> Shop: Baba Farid Mobiles, Jamal Chowk, Depalpur Road, Pakpattan
> Related: `docs/deployment.md` §2.4 and §4.3, `README.md` §3/§6,
> `docs/architecture.md` §2.1.

---

## What it is

The admin panel is **not a separate app**. It is the **Flutter Web build
of the same `mobile_app/` codebase** that runs on the shop's Android
phones — same screens, same business logic, same API, compiled for the
browser. There is no second frontend to maintain: a fix in `mobile_app/`
shows up in the panel on the next web build.

It is meant for the **owner/manager on a laptop or desktop**: full-screen
dashboard, reports and charts, stock and ledger management, settings and
user management — everything the phone app does, with room for tables and
charts.

---

## Build

From the project root (Flutter SDK required — see
`docs/deployment.md` §1):

```bash
cd mobile_app
flutter pub get
flutter build web --release
```

This produces the static site in `mobile_app/build/web/` (an `index.html`
plus the compiled Dart/JS, assets and fonts). No server-side code is
generated — the panel is pure static files that call the backend API.

Build variants:

```bash
flutter build web --release              # production (default)
flutter build web --debug                # debug build, for testing only
flutter build web --release --web-renderer canvaskit   # default renderer
flutter build web --release --web-renderer html        # lighter, if canvaskit is slow on an old PC
```

> The panel talks to the **same backend API** as the Android app
> (default `http://localhost:3000/api/v1`, configurable — see below).
> The backend must be running before the panel can log in.

---

## Run / serve

### Local preview (testing only)

```bash
cd mobile_app
flutter run -d chrome            # hot-reload dev server on http://localhost:8080
# or serve the release build:
python3 -m http.server 8080 --directory build/web
```

### Production (VPS)

Copy `build/web/` to the server and serve it with nginx — full config in
`docs/deployment.md` §4.3. The short version:

```bash
# on your machine
scp -r mobile_app/build/web/* user@server:/opt/baba-farid-mobiles/admin-web/

# nginx serves /opt/baba-farid-mobiles/admin-web/ at https://shop.example.com/
# and proxies /api/ to the Node backend on port 3000
```

The panel is a single-page app: nginx must fall back to `index.html`
(`try_files $uri $uri/ /index.html;`) so deep links and refreshes work.

---

## Configuration

The panel uses the same config as the mobile app:

- **API base URL** — where the backend lives. Default:
  `http://localhost:3000/api/v1`. For a deployed panel, set it to the
  public API address (e.g. `https://shop.example.com/api/v1`) before
  building, per the config in `mobile_app/lib/core/` (see `DECISIONS.md`
  §4). The backend's `CORS_ORIGIN` (in `backend/.env`) must include the
  panel's origin, or the browser will block API calls.
- **Auth** — log in with the same users as the app. Demo logins from
  `database/seed.sql` (change after first login): `admin` / `admin123`
  (Owner), `manager` / `manager123` (Manager), `cashier` / `cashier123`
  (Cashier). The panel is most useful as Owner or Manager; a Cashier
  login works but hides cost prices and profit, exactly like the app.
- **Theme / language** — the Hacker theme (dark, neon green) is the
  default; switch theme and English/Urdu in Settings, same as the app.

---

## What the panel can and cannot do

| Can | Cannot |
|---|---|
| Everything the Android app does (POS, stock, ledger, installments, repairs, expenses, reports, settings, users) | Print to a Bluetooth thermal printer (no Bluetooth in a browser — use the A4 PDF invoice and print that, or print from the Android app) |
| Open on any laptop/desktop browser, no install | Scan barcodes/IMEIs with the phone camera (use a USB barcode scanner, which types the code like a keyboard, or type the IMEI) |
| Show the same live data as the shop phones (same API, same database) | Work offline — the web build needs the network. Offline-first selling is the Android app's job (see `docs/sync.md`) |

---

## Updating the panel

```bash
cd mobile_app
git pull
flutter pub get
flutter build web --release
scp -r build/web/* user@server:/opt/baba-farid-mobiles/admin-web/
# no service restart needed — it is static files; just hard-refresh the browser
```

Rebuild the panel whenever `mobile_app/` changes; the backend can be
updated independently (see `docs/deployment.md` §4.4).
