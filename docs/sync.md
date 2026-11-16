# Offline Sync Design — Baba Farid Mobiles Billing & Inventory System

> Module 7 · Shop: Baba Farid Mobiles, Pakpattan · Currency: PKR
> Related: `docs/architecture.md` §4, `database/schema.sql`
> (§10 `sync_logs`, `client_uuid` columns), `DECISIONS.md` §24,
> `docs/testing.md` §4 case 6.

---

## 1. The problem

The shop's internet is unreliable, but the counter can never stop. A sale
must save and print with **zero connectivity**, and everything must reach
the server when the connection returns — exactly once, with nothing lost
and nothing double-counted. Two devices (counter phone + owner's phone)
can also change the same data while offline.

Design principles (from `docs/architecture.md`):

1. **Local first.** The Flutter app reads and writes local SQLite (drift)
   only. The server is never on the critical path of a sale.
2. **Money is append-only.** Sales, payments, ledger entries and audit logs
   are never edited in place, so a sync can never overwrite money — it can
   only add new rows.
3. **One source of truth for stock.** A phone is a unique IMEI item; the
   server is the final authority on IMEI status.

---

## 2. The outbox pattern

Every local mutation is recorded **twice, in one local transaction**:

1. The business row itself (e.g. a `sales` row + its `sale_items`, the IMEI
   status change, the ledger entry) in the local SQLite tables, which mirror
   `database/schema.sql` (same names/columns where practical).
2. One row in the local **`outbox`** table describing the operation.

```text
outbox (actual local table — drift `Outbox` in app_database.dart)
------
id            TEXT PRIMARY KEY        -- local UUID for the outbox row itself
client_uuid   TEXT NOT NULL UNIQUE    -- outbox row's own key (NOT the sale's
                                      -- idempotency key; see §3.1)
table_name    TEXT NOT NULL           -- 'sales' | 'customers' | 'products' | ...
operation     TEXT NOT NULL           -- 'insert' | 'update' | 'delete'
payload       TEXT NOT NULL           -- full JSON of the row(s) to apply
synced        INTEGER NOT NULL        -- 0 = pending, 1 = synced
created_at    TEXT NOT NULL           -- ISO 8601, local time
```

Rules:

- The business row and its outbox row are written in the **same local
  transaction** — either both exist or neither does. A crash can never
  leave a sale without an outbox row.
- Outbox rows are processed **in creation order** (FIFO). Order matters:
  a payment for a sale must not arrive before the sale itself.
- A row leaves the outbox only when the server confirms it (`synced = 1`)
  or reports it as an error/conflict the owner must resolve (logged in
  `sync_logs`, action `conflict`; see §3.1). Failed rows stay pending
  and are retried on the next sync. There is no per-row retry counter or
  `last_error` column — the conflict history lives in `sync_logs`.
- `client_uuid` is generated on the device with `gen_random_uuid`-style
  random UUIDs (the same idea as the server's `gen_random_uuid()`), so two
  offline devices never generate the same key. Note the two different
  keys: the outbox row's `client_uuid` and the sale's `client_uuid`
  (stored inside the payload, set when the bill was created) — the
  server's idempotency key is the SALE's one (§3.1).

---

## 3. Push / pull endpoints

Base URL: `/api/v1` (default `http://localhost:3000/api/v1`, see
`DECISIONS.md` §4). All sync calls send `Authorization: Bearer <JWT>` and
use the standard envelope `{ ok, data, error }`.

### 3.1 Push — `POST /api/v1/sync/push`

The device sends its pending **sales** only. The server has no generic
push endpoint — there is no `{ device_id, operations }` shape (sending
it returns 400 `deviceId: Required`). Only `sales`/`insert` outbox rows
are converted and sent; every other outbox row stays pending (see below).

**Request** (camelCase keys — see `backend/src/modules/sync/schemas.ts`)

```json
{
  "deviceId": "POS-01",
  "sales": [
    {
      "clientUuid": "40000000-0000-4000-8000-000000000001",
      "customerId": null,
      "customerName": "Walk-in",
      "customerPhone": "03001234567",
      "items": [
        { "variantId": "14000000-0000-4000-8000-000000000001",
          "imei1": "860123456789012",
          "quantity": 1, "unitPrice": 54000, "discount": 0 }
      ],
      "discountAmount": 0, "discountPercent": 0, "taxAmount": 0,
      "paidAmount": 54000, "paymentMethod": "cash",
      "notes": "...", "adminApprovedBy": null
    }
  ]
}
```

The sale's idempotency key is the `client_uuid` stored in the outbox
payload (set when the bill was created), NOT the outbox row's own
`clientUuid`. Phones are identified by IMEI number — the phone does not
know the server-side `imei_item` UUID, so the client resolves each
local `imei_item_id` to its IMEI number before sending; a line whose
IMEI cannot be resolved is never sent (it is logged as a conflict and
flagged on the local sale instead of being sent with a guessed IMEI).

**Response**

```json
{
  "ok": true,
  "data": {
    "accepted": [ { "...created bill, snake_case client_uuid..." } ],
    "skipped": [ { "clientUuid": "...", "reason": "already_synced" } ],
    "errors": [ { "clientUuid": "...",
                  "error": "IMEI 860123456789011 is not in stock on the server" } ],
    "serverTime": "2026-11-16T00:46:37.211Z"
  }
}
```

Note the mixed casing: `accepted` rows are created bills (snake_case
`client_uuid`); `skipped`/`errors` entries use camelCase `clientUuid`.
The client handles both.

**Server behaviour (per sale, in its own transaction):**

1. Look up `client_uuid` in `sales`.
   - **Found → `skipped` (`already_synced`), apply nothing.** This is
     the idempotency guarantee: a retry after a dropped connection, or
     a double-send, can never create a second bill.
   - **Not found → validate, then apply** through the same `createSale`
     transaction as an online bill: IMEI must be `available` (resolved
     from the IMEI number), totals must reconcile,
     `paid_amount <= grand_total`, role/min-price rules apply.
2. A sale that fails validation or a business rule lands in `errors`
   with its `clientUuid` and the message; the other sales in the same
   push are still applied. The client logs each error as a conflict
   (`sync_logs`, action `conflict`), marks that outbox row synced so a
   permanently rejected sale is not retried forever, and flags the
   local sale's notes with `[SYNC CONFLICT: ...]` for IMEI errors. A
   sale that appears in none of `accepted`/`skipped`/`errors` stays
   pending — its outcome is unknown, and retrying is safe.
3. The push is recorded in `sync_logs` (`device_id`, `user_id`,
   `entity_type = 'sale'`, `action = 'push'`, counts in `detail`).

**What does NOT push (stays pending, never marked synced):** the server
has no endpoint for any other entity, so outbox rows for products,
customers, suppliers, purchases, payments, repairs, expenses, returns
and settings — and non-`insert` sale rows such as a cancel update —
cannot be pushed and are left pending by design. Marking them synced
would silently lose data. They reach the server when their normal
online API call succeeds (e.g. `POST /customers`, `POST /products`,
`POST /purchases`, `POST /sales/:id/cancel` — the repositories call
those directly while online); the outbox row for them is then cleared
by that success path. Until such a path exists for an entity, its
outbox rows honestly remain pending and visible as "N pending" on the
home screen — that is the known limitation, not a bug to work around
by faking a push.

A push batch should be small (max ~50 sales per request; the server
caps at 200) so a flaky connection can make progress instead of timing
out on a huge batch.

### 3.2 Pull — `GET /api/v1/sync/pull?since=<ISO-8601 timestamp>`

The device asks for everything that changed on the server since its last
successful pull.

**Request**

```http
GET /api/v1/sync/pull?since=2026-11-15T00:00:00Z
Authorization: Bearer <JWT>
```

**Response** — per-table arrays, NOT a `changes` list
(see `backend/src/modules/sync/service.ts` `pullChanges`):

```json
{
  "ok": true,
  "data": {
    "serverTime": "2026-11-16T07:30:00Z",
    "products": [ { "...product row..." } ],
    "variants": [ { "...product_variant row..." } ],
    "customers": [ { "...customer row..." } ],
    "suppliers": [ { "...supplier row..." } ],
    "sales": [ { "...sale row + user_name..." } ],
    "settings": { "shop.name": "Baba Farid Mobiles", "tax.enabled": false }
  }
}
```

**Client behaviour** (`mobile_app/lib/data/sync/sync_engine.dart`):

- `variants` maps to the local `product_variants` table; `settings` is
  a flat object — each value is JSON-encoded into the local `settings`
  table (whose `value` column holds JSON text). Pulled `sales` rows
  carry an extra joined `user_name` field, which the client's column
  whitelist drops before writing.
- Apply changes in the order received, inside local transactions.
- Save `serverTime` as the new `since` watermark — but only after the
  whole batch is applied, so an interrupted pull re-fetches the same batch
  (applying it twice must be harmless: upserts keyed by id).
- Master data (products, variants, customers, suppliers, settings) is
  applied server-wins (INSERT OR REPLACE); sales are append-only
  (INSERT OR IGNORE — a pulled sale never overwrites a local one). The
  IMEI safety rule still applies: a locally-sold IMEI is never
  reverted to `available` by a pull.
- The pull covers **master data and other devices' records**: products,
  variants, prices, new IMEI stock, customers, other-device sales
  (read-only on this device), settings, and counters.
- Pulls happen on app start, after every successful push, and on a timer
  (every 5 minutes while online). A manual "Sync now" button forces one.

### 3.3 Sync status on the device

The app shows one sync badge on the home screen:

| State | Meaning |
|---|---|
| `Synced` | Outbox empty, last pull < 5 min ago. |
| `Syncing…` | A push/pull is in progress. |
| `N pending` | N outbox rows waiting (offline or failed). Tap for detail. |
| `Conflict` | At least one row needs the owner — tap to open the conflict screen. |

---

## 4. Idempotency by `client_uuid`

- **Every money record created on a device carries a `client_uuid`:**
  `sales.client_uuid`, `purchases.client_uuid`, `payments.client_uuid`
  (all `UNIQUE` in `database/schema.sql`).
- The `client_uuid` is generated **once**, when the local row is created,
  and never changes — not on retry, not on edit.
- The server treats `client_uuid` as the identity of the operation:
  same key → same result, never applied twice. A retry after a network
  drop, a phone restart mid-sync, or a double-tap all collapse to one
  server row.
- Non-money records (products, customers) are synced by **id + updated_at**
  (upsert), not by `client_uuid` — they can be edited, so they need the
  conflict rules in §5 instead.

---

## 5. Conflict rules

| Data | Rule | Why |
|---|---|---|
| **Master data** (product name/price, variant price, customer details, settings) | **Server wins.** The device's older change is discarded; the server value is applied locally. There is no push endpoint for master data (§3.1), so an offline master-data edit made on the device cannot be re-applied by sync — it must be redone while online through the normal API. | Prices and names must be the same on every device; last-writer-wins would silently lose the owner's price change. |
| **Money records** (sales, payments, ledger entries, returns) | **Append-only, never overwritten.** A synced money row is immutable. A correction is a new row (return, reversal, adjustment) that references the original. | Money can never be lost or double-counted by a sync. |
| **Stock quantities** (accessories) | Derived, not synced directly: quantity changes only through sales, purchases and returns, which are themselves synced. The server recomputes stock from those events. | Prevents two devices from both "setting" quantity to different values. |
| **Counters** (invoice numbers) | Server-assigned. The device requests the next number from the server when online; offline it uses a reserved block (e.g. `INV-000006`…`INV-000099` pre-allocated per device) so numbers never collide. | Invoice numbers must be unique and sequential per branch. |
| **IMEI status** | **Server is the final authority.** See §6. | A phone exists once; it can only be sold once. |

A conflict is never silent: the device marks the outbox row `conflict`,
shows it on the conflict screen, and writes a `sync_logs` row with
`action = 'conflict'` and the detail. The owner resolves it in the app
(keep server version / re-apply mine / void the local sale).

---

## 6. IMEI conflict handling

This is the one hard conflict in the system: two devices sell the **same
IMEI** while both offline.

1. Device A sells IMEI `X` offline; device B sells IMEI `X` offline.
   Both sales are valid locally (the IMEI was `available` on both).
2. Device A syncs first → server applies it, IMEI `X` becomes `sold`.
3. Device B pushes → the server finds IMEI `X` already `sold` and returns
   `status: "conflict"`, error `"IMEI X already sold"`.
4. Device B marks the sale as conflicted and **flags it prominently**:
   the sale stays visible locally but is marked "SYNC CONFLICT — needs
   owner", and the cashier cannot print a second warranty for it.
5. The owner resolves it in the app: the physical phone is in only one
   customer's hands, so one of the two sales is wrong. The owner voids the
   wrong sale (a `sale_returns`-style reversal row, append-only) and the
   right sale stands. Both devices learn the outcome on the next pull.

Prevention (reduces how often this happens): the POS warns if an IMEI was
*reserved* by another device recently, and the pull runs every 5 minutes
while online so the window for a double-sale is small.

---

## 7. `sync_logs` (server side)

`sync_logs` in `database/schema.sql` records every push/pull/conflict:

| Column | Use |
|---|---|
| `device_id` | Which device synced (`POS-01`, owner's phone, …). |
| `user_id` | Who was logged in on that device. |
| `entity_type` / `entity_id` | What was synced. |
| `action` | `push` / `pull` / `conflict`. |
| `detail` (JSONB) | `client_uuid`, result, error text, row counts. |
| `created_at` | When. |

Use it to answer "did this sale reach the server?" — search by
`client_uuid` in `detail`, or by `entity_id` = the sale id. The seed data
(`database/seed.sql` §26) contains two example rows (one push, one pull).

---

## 8. How to test sync

### 8.1 Idempotency (no double-apply)

1. Seed the database (`database/seed.sql`).
2. Create a sale offline on the app (or call the push endpoint twice with
   the same payload and the same `clientUuid`).
3. Push, then push the **exact same batch again**.
4. **Check:** `SELECT count(*) FROM sales WHERE client_uuid = '<the key>'`
   returns **1**. The second push returns `accepted: []` and
   `skipped: [{ clientUuid: '<the key>', reason: 'already_synced' }]`.
   (Verified live 2026-11-16: sale `INV-000006`, clientUuid
   `11111111-2222-4333-8444-555555555501`, IMEI `860123456789013`.)

### 8.2 Offline sale, then sync

1. Turn off Wi-Fi/mobile data on the device.
2. Make a sale and print the receipt (must work — nothing should block).
3. **Check:** the sale is in local SQLite and there is 1 `pending` row in
   the local outbox; the home screen shows "1 pending".
4. Turn the internet back on and wait (or tap "Sync now").
5. **Check:** the sale appears on the server (`SELECT * FROM sales WHERE
   invoice_no = ...`), the outbox row is `synced = 1`, the badge reads "Synced".

### 8.3 Pull

1. On the server (or another device), change a product price.
2. On this device, pull (or wait ≤ 5 minutes).
3. **Check:** the new price shows on the POS, and the old price is gone —
   server wins for master data.

### 8.4 IMEI conflict

1. On two devices (or two app installs), both offline, sell the **same**
   available IMEI from the seed data (e.g. `860123456789012`).
2. Sync device A → applied.
3. Sync device B → **Check:** B's push returns that sale in `errors`
   (e.g. `"IMEI 860123456789012 is not in stock on the server"` — the
   server resolves the IMEI and finds it already sold), the sale is
   flagged on B with `[SYNC CONFLICT: ...]` in its notes, and a
   `sync_logs` row with `action = 'conflict'` exists on the device
   (the server records the push itself in `sync_logs`, action `push`).
   The IMEI is `sold` exactly once in the database.

### 8.5 Interrupted push

1. Start a push of several sales and kill the app / drop the network
   halfway.
2. Reconnect and push again.
3. **Check:** every sale exists exactly once on the server (idempotency),
   and no sale is half-applied (each operation is one server transaction).

### 8.6 Clock skew

Devices with wrong clocks must not break ordering: ordering uses
**server timestamps** for pull windows and **creation order** for the
outbox, never the device clock alone. Set a device clock 1 hour ahead and
repeat 8.2 — the sale must still sync exactly once.

---

## 9. What sync does NOT do (known limits)

- **Only sales push.** The server has no generic push endpoint, so
  offline-created products, customers, purchases, repairs, expenses and
  other entities do NOT sync through the outbox — their rows stay
  pending until their normal online API call succeeds (§3.1). Do not
  treat "N pending" for those rows as a stuck sale.
- **No real-time sync.** Pulls are periodic (≤ 5 min), not push-based.
  Two devices can briefly disagree about stock — the IMEI rules in §6 are
  what keep that safe.
- **No conflict-free offline price edits.** If two devices edit the same
  price offline, server-wins discards one edit. Price changes should be
  made on one device (ideally the owner's) while online.
- **No sync of the local audit log.** The server writes its own audit rows
  from API requests; the device's local audit trail stays on the device.
- **No multi-branch sync yet.** `branch_id` exists on the main tables, but
  cross-branch filtering is a later milestone (see `PLAN.md` M7/M8).
