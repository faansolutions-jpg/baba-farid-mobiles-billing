# Deployment Guide — Baba Farid Mobiles Billing & Inventory System

> Module 8 · Shop: Baba Farid Mobiles, Jamal Chowk, Depalpur Road, Pakpattan
> Related: `README.md`, `docs/architecture.md` §7, `docs/testing.md`,
> `docs/sync.md`, `backend/.env.example`, `admin_panel/README.md`.

---

## 1. Requirements

| Component | Version | Notes |
|---|---|---|
| PostgreSQL | **16** | Server database. `schema.sql` uses `gen_random_uuid()` (`pgcrypto`) and `NUMERIC(12,0)` money columns. |
| Node.js | **20+** (minimum 18, per `backend/package.json` `engines`) | Backend API. Use the LTS release. |
| npm | ships with Node | |
| Flutter | latest stable (3.x) | Android app + web admin panel. Install from <https://docs.flutter.dev/get-started/install>. |
| Android SDK | via Android Studio | Only needed to build the APK. |
| Git | any recent | To clone/update the project. |
| (Server) Ubuntu 22.04/24.04 LTS | — | Recommended VPS OS. 2 GB RAM minimum for Node + PostgreSQL on one box. |

> **Note (2026-11-16):** Flutter/Dart SDK and PostgreSQL are **not**
> installed on the machine this project was built on (see `DECISIONS.md`
> §30–31), so the Flutter build and the database were verified by review
> and parsing, not by running them here. Run the steps below on a machine
> with the tools installed.

---

## 2. Setup

### 2.1 Database (PostgreSQL 16)

```bash
# Ubuntu
sudo apt update && sudo apt install -y postgresql-16

# Create the database and a dedicated user (do NOT run the app as postgres)
sudo -u postgres psql -c "CREATE USER shopapp WITH PASSWORD '<strong-password>';"
sudo -u postgres psql -c "CREATE DATABASE shopdb OWNER shopapp;"

# Load schema + seed data (from the project root)
psql -d shopdb -f database/schema.sql
psql -d shopdb -f database/seed.sql
```

Verify with the checks in `docs/testing.md` §2.1 (expect 30 IMEI items,
5 sold; total seed profit 28770).

### 2.2 Backend

```bash
cd backend
npm install
cp .env.example .env   # then edit .env — see §3, never commit .env
npm run build          # tsc — compiles TypeScript to dist/
npm start              # node dist/server.js — serves on $PORT (default 3000)
```

For development, `npm run dev` (`tsx watch src/server.ts`) auto-reloads.

Check it is up:

```bash
curl http://localhost:3000/api/v1/health   # expect { "ok": true, ... }
```

> If there is no `/health` endpoint yet (Module 4 is still being written),
> check `curl http://localhost:3000/api/v1/auth/login` returns a JSON error
> (not a connection refused) — that proves the server is listening.

### 2.3 Flutter app (Android)

```bash
cd mobile_app
flutter pub get
flutter run                 # debug on a connected phone/emulator
flutter build apk --debug   # debug APK
flutter build apk --release # release APK for the shop counter phone
```

The app talks to the backend URL from its config (default
`http://localhost:3000/api/v1` — see `DECISIONS.md` §4). For a real phone,
set the config to the server's LAN address or public domain before
building the release APK.

### 2.4 Admin panel (Flutter Web)

Same codebase as the app — see `admin_panel/README.md`. In short:

```bash
cd mobile_app
flutter build web --release
# serve the output (build/web/) — see §4.3
```

---

## 3. Environment variables

Copy `backend/.env.example` to `backend/.env` and fill in real values.
**Never commit `.env` to git.** The variables (as defined in
`.env.example`):

| Variable | Example / notes |
|---|---|
| `PORT` | `3000` |
| `NODE_ENV` | `development` / `production` |
| `CORS_ORIGIN` | `http://localhost:8080,http://localhost:3000` — comma-separated allowed origins for the app / web admin. In production, list only your real domains (never `*`). |
| `DATABASE_URL` | `postgres://shopapp:<password>@localhost:5432/shopdb` |
| `JWT_ACCESS_SECRET` | Long random string (≥ 64 hex chars). Generate with `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`. |
| `JWT_REFRESH_SECRET` | A **different** long random string, generated the same way. |
| `JWT_ACCESS_EXPIRES_IN` | `15m` |
| `JWT_REFRESH_EXPIRES_IN` | `7d` |
| `BCRYPT_ROUNDS` | `12` (spec — do not lower it) |
| `LOGIN_RATE_LIMIT_MAX` | `5` (failed logins per IP per 15 minutes, then lockout) |

After deploying, **change the demo passwords** (`admin/admin123`,
`manager/manager123`, `cashier/cashier123` from `database/seed.sql`) in
Settings → Users. The seed passwords are public by design — they are only
for a first login.

---

## 4. Deploy (VPS)

A single small VPS runs everything: Node backend + PostgreSQL on the same
box, Flutter Web admin panel served as static files, and the Android app
installed on the shop phones.

### 4.1 Server layout

```text
/opt/baba-farid-mobiles/
├── backend/            # git checkout; npm install; npm run build
│   ├── .env            # real secrets (not in git)
│   └── dist/           # compiled output (npm run build)
├── admin-web/          # flutter build web output (build/web/)
└── backups/            # local backup files (see §5)
```

### 4.2 Run the backend as a service (systemd)

```ini
# /etc/systemd/system/baba-farid-backend.service
[Unit]
Description=Baba Farid Mobiles backend API
After=network.target postgresql.service

[Service]
Type=simple
User=shopapp
WorkingDirectory=/opt/baba-farid-mobiles/backend
ExecStart=/usr/bin/node dist/server.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now baba-farid-backend
sudo systemctl status baba-farid-backend
sudo journalctl -u baba-farid-backend -f   # logs
```

### 4.3 Reverse proxy (nginx) + HTTPS

Put nginx in front of Node. It serves the admin panel as static files,
proxies `/api/` to the backend, and terminates HTTPS (Let's Encrypt).

```nginx
server {
    listen 80;
    server_name shop.example.com;   # your domain
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name shop.example.com;

    ssl_certificate     /etc/letsencrypt/live/shop.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/shop.example.com/privkey.pem;

    # Admin panel (Flutter Web static files)
    location / {
        root /opt/baba-farid-mobiles/admin-web;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
sudo certbot --nginx -d shop.example.com   # free HTTPS certificate
sudo nginx -t && sudo systemctl reload nginx
```

Notes:

- The API is **never exposed directly** — only through nginx on 443.
  Close port 3000 in the firewall (`sudo ufw allow 443/tcp` only, plus SSH).
- PostgreSQL listens on localhost only (`listen_addresses = 'localhost'` in
  `postgresql.conf`); the app server and the database are on the same box,
  so the database port is never public.
- `CORS_ORIGIN` must include the admin panel's origin
  (`https://shop.example.com`); the Android app is not browser-based, so it
  is not CORS-limited, but it still needs the JWT.

### 4.4 Updating the deployment

```bash
cd /opt/baba-farid-mobiles/backend
git pull
npm install
npm run build
npm test                    # run the backend suite before restarting
sudo systemctl restart baba-farid-backend
```

Database changes go through versioned migrations in
`database/migrations/` — never edit `schema.sql` in place on a live
database. Apply a migration with
`psql -d shopdb -f database/migrations/<version>.sql`, and back up first
(§5).

---

## 5. Backup & restore

### 5.1 Local backup (built in — do this daily)

```bash
# Full database dump (run from cron, e.g. every night at 02:00)
pg_dump -U shopapp -d shopdb -F c -f /opt/baba-farid-mobiles/backups/shopdb-$(date +%F).dump

# Keep the last 14 days, delete older dumps
find /opt/baba-farid-mobiles/backups -name 'shopdb-*.dump' -mtime +14 -delete
```

The app also has a **Backup** screen (Settings → Backup): it exports a
JSON + SQLite copy of the device data, AES-256 encrypted, to a file the
owner can keep. Restore from Settings → Backup → Restore, or from a dump:

```bash
# Restore a dump into a fresh database
dropdb shopdb && createdb shopdb -O shopapp
pg_restore -U shopapp -d shopdb /opt/baba-farid-mobiles/backups/shopdb-2026-11-16.dump
```

**Test the restore** at least once a month on a spare database — a backup
you have never restored is not a backup:

```bash
createdb shopdb_restore_test -O shopapp
pg_restore -U shopapp -d shopdb_restore_test /opt/baba-farid-mobiles/backups/shopdb-$(date +%F).dump
psql -d shopdb_restore_test -c "SELECT count(*) FROM sales;"   # expect the live count
dropdb shopdb_restore_test
```

### 5.2 Google Drive (optional, manual)

There is **no Google Drive API integration** in the app (no credentials —
see `DECISIONS.md` §25). The documented optional step is manual:

1. Copy the latest dump from `/opt/baba-farid-mobiles/backups/` (or the
   app's exported backup file) to a folder on the owner's phone/laptop.
2. Upload it to Google Drive (account: `baba.farid.mobiles.bfw@gmail.com`)
   into a folder named **Baba Farid Mobiles — Backups**.
3. Keep the Drive copy in addition to, never instead of, the local copy.

If Drive integration is wanted later, it is a small job: a service-account
key + a nightly `rclone` upload of the backups folder.

### 5.3 What to back up

- **PostgreSQL dump** — the whole shop (sales, stock, ledger, everything).
  This is the critical one.
- **`.env`** — kept separately, encrypted, never in the dump or in git.
- **Uploaded files** (product images, if any) — the `uploads/` folder next
  to the backend, if it exists.

---

## 6. Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| `curl` to the API: connection refused | Backend not running: `systemctl status baba-farid-backend`; check `journalctl`. Port in `.env` must match the nginx `proxy_pass`. |
| `500` / database errors on first start | `DATABASE_URL` wrong, or schema not loaded: re-run `psql -d shopdb -f database/schema.sql`. |
| Login fails with correct password | Seed not loaded (no users), or password was changed. Reset by re-running `seed.sql` on a **fresh** database only — never on live data (it uses `ON CONFLICT DO NOTHING`, so it will not overwrite a changed password). |
| App cannot reach the server | Phone on a different network, or the config still points at `localhost`. Set the API base URL to the server's domain/IP and rebuild. |
| `flutter build web` fails | Flutter SDK not installed or not on `PATH`. See §1. |
| Disk full on the VPS | Old backups / logs. Check `du -sh /opt/baba-farid-mobiles/backups`, enforce the 14-day retention in §5.1, and rotate nginx logs. |
