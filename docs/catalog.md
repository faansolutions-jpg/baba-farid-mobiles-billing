# Accessories Master Catalog

> Baba Farid Mobiles — pre-loaded accessory catalog for the Punjab
> (Pakistan) mobile-accessories market. **1,726 items, version 1.0.0.**
>
> ⚠️ **All prices are ESTIMATED** Punjab-market prices in whole PKR at
> generation time. They are **not live market rates** — accessory prices
> change often. The shopkeeper confirms the real buying price at stock-in,
> and every record carries `"estimated": true`.

## Files

| File | What it is |
|---|---|
| `scripts/generate_catalog.py` | **The source of truth.** Builds the catalog from matrices (categories, brands, device models, variants) and writes the JSON + SQL below. Edit this, never the outputs. |
| `database/catalog/accessories_catalog.json` | Generated catalog: `{version, generated_at, item_count, price_note, items[]}`. Reusable — the same file can later be loaded into the web software. |
| `database/migrations/001_accessories_catalog.sql` | Idempotent migration creating the `catalog_*` tables and loading the items. Creates **new tables only**; it does not modify any existing table. |
| `backend/src/modules/catalog/` | `routes.ts`, `schemas.ts`, `service.ts` — Express API (see below). |
| `mobile_app/lib/data/database/catalog_tables.dart` | drift table definitions mirroring the SQL tables. |
| `mobile_app/lib/data/database/catalog_database.dart` | `CatalogDatabase` — drift, separate SQLite file `catalog.db`. |
| `mobile_app/lib/features/catalog/catalog_models.dart` | `CatalogItem` model (`id == sku`). |
| `mobile_app/lib/features/catalog/catalog_repository.dart` | `CatalogRepository` interface + `CatalogRepositoryImpl`. |
| `mobile_app/lib/features/catalog/catalog_search.dart` | Fuzzy + Roman-Urdu search helper. |
| `mobile_app/test/catalog_test.dart` | Unit tests (in-memory drift DB). |

## Catalog contents (v1.0.0 — 1,726 items)

| Category | Items | Notes |
|---|---|---|
| Chargers | 97 | Wall 10–100W, car, wireless, GaN multi-port |
| Cables | 216 | Type-C / Micro USB / Lightning / C-to-C / C-to-Lightning / 3-in-1, 1–2m, braided |
| Power Banks | 86 | 5,000–30,000 mAh, mini, solar, wireless |
| Audio | 78 | Wired/BT handsfree, TWS earbuds, neckbands, headphones, speakers |
| Protection | 865 | Covers + glass mapped to **132 device models** (see below) |
| Holders | 28 | Car, tripod, selfie stick, ring light, gimbal, desk, bike |
| Memory | 31 | SD cards, USB/OTG drives, card readers |
| Smart Accessories | 27 | Smart watches, bands, straps, trackers |
| Repair Parts | 237 | LCDs, batteries, charging flex, speakers, mics, back glass, tools |
| Others | 61 | SIM trays, ejector pins, adapters, HDMI, laptop, gaming |

**Device models covered (132):** Apple iPhone 11–16 series (23),
Samsung Galaxy A/M/S/Note/Z (25), Infinix Hot/Note/Smart (12),
Tecno Spark/Camon/Pova/Pop/Phantom (12), Vivo Y/V (13), Oppo A/Reno/F
(11), Xiaomi/Redmi/Poco (16), Realme C/Narzo/number/GT (12), Huawei
Y/Nova/P/Mate (8). Covers (silicone / clear TPU / hard / leather flip)
and tempered glass (normal / 9D / privacy / matte) are generated per
model, so one tap on a model gives all its variants.

**SKU format:** `ACC-<CATEGORY>-<BRAND>-<VARIANT>-<NNN>`,
e.g. `ACC-CHG-ANK-25W-001` (Anker 25W wall charger),
`ACC-PRT-GEN-GLS-016` (tempered glass, Generic). SKUs are unique.

**Item fields:** `sku, category, brand, name_en, name_ur,
model_compatibility, colors[], variants[], purchase_price_est,
sale_price_est, min_price, unit, barcode (null until scanned),
is_custom (false), estimated (true), low_stock_threshold`.

**Urdu names** are composed from a translation map in the generator
(`URDU_MAP` — Charger=چارجر, Cable=کیبل, Power Bank=پاور بینک,
Earbuds=ایئربڈز, Handsfree=ہینڈزفری, Back Cover=بیک کور,
Tempered Glass=ٹیمپرڈ گلاس, Battery=بیٹری, Watch=گھڑی,
Speaker=اسپیکر, …). Brand names, model names and numbers stay in Latin
script, as shopkeepers write them.

## How to add categories / items

1. Edit the matrices in `scripts/generate_catalog.py`:
   - new category → add to `CATEGORIES` + `CAT_CODE`;
   - new brand → add to `BRANDS`;
   - new device model → add to `DEVICE_MODELS` (covers/glass/LCD/
     battery/flex/SIM-tray variants are generated automatically);
   - new product line → add a `build_*()` function and list it in
     `BUILDERS`;
   - new Urdu word → add to `URDU_MAP`.
2. Bump `VERSION` at the top of the script.
3. Re-run the generator from the project root:
   ```bash
   python3 scripts/generate_catalog.py
   ```
   It rewrites both `database/catalog/accessories_catalog.json` and
   `database/migrations/001_accessories_catalog.sql`, then verifies:
   1,500+ items, unique SKUs, valid prices, `estimated: true` everywhere.
   ```bash
   python3 scripts/generate_catalog.py --check   # verify without rewriting
   ```

## How a version update works

A new catalog version is **additive and safe**:

- **New SKUs** are inserted (with an empty `catalog_stock` row).
- **Existing non-custom items** get their *estimated* prices refreshed
  (`purchase_price_est`, `sale_price_est`, `min_price` only).
- **Never touched:** `catalog_stock` quantities, `barcode_links`,
  `is_custom` items, and any price the shopkeeper set. The shop's own
  data always wins over the catalog.

The SQL migration shows the pattern in its commented block at the end
(`ON CONFLICT (sku) DO UPDATE … WHERE catalog_items.is_custom = FALSE`).
The same rule is implemented in `CatalogRepository.applyCatalogUpdate`
(app) and `applyCatalogUpdate` in `backend/src/modules/catalog/service.ts`
(server). The applied version is recorded in `catalog_versions`.

## Backend API

Mount (after the Module 4 backend agent finishes — do **not** wire it
into `app.ts` yet):

```ts
import catalogRouter from './modules/catalog/routes';
app.use('/api/v1/catalog', catalogRouter);
```

| Endpoint | Method | Role | Notes |
|---|---|---|---|
| `/api/v1/catalog?search=&category=&brand=&page=&limit=` | GET | all | Paginated list; cashiers never receive `purchase_price_est` |
| `/api/v1/catalog/:sku` | GET | all | Item + device models + stock |
| `/api/v1/catalog/stock-in` | POST | staff | `{sku, qty, price?, supplier?, date?}` |
| `/api/v1/catalog/bulk-stock-in` | POST | staff | `{items:[{sku,qty}], price?, supplier?}` — **one transaction, all or nothing** |
| `/api/v1/catalog/barcode-link` | POST | staff | `{barcode, sku}` — permanent; re-linking to another SKU is a conflict |
| `/api/v1/catalog/barcode/:barcode` | GET | all | Lookup by linked barcode |
| `/api/v1/catalog/custom-item` | POST | staff | Shopkeeper's own item (`is_custom: true`) |
| `/api/v1/catalog/low-stock` | GET | all | Items at/below threshold |
| `/api/v1/catalog/reorder-list` | GET | all | Low-stock items grouped by supplier |
| `/api/v1/catalog/stock-count` | POST | staff | `{sku, countedQty, note}` — writes `stock_counts`, adjusts stock |
| `/api/v1/catalog/version` | GET | all | Latest applied catalog version |
| `/api/v1/catalog/import` | POST | staff | `{rows:[...]}` or `{csv:"..."}` — auto-match by SKU, then barcode, then normalised name; unmatched rows with sku+name become custom items |

All mutating endpoints write an audit-log row in the same transaction.
Response envelope is the standard `{ ok, data, error }`.

## App (Flutter) usage

```dart
final db = CatalogDatabase();                 // opens catalog.db
final repo = CatalogRepositoryImpl(db);

final results = await repo.search('type c cabel'); // fuzzy + Roman Urdu
await repo.stockIn('ACC-CHG-ANK-25W-001', 10,
    price: 2100, supplier: 'Hall Road');
await repo.bulkStockIn({'ACC-CAB-ANK-TC10-001': 20});
await repo.linkBarcode('8961234567890', 'ACC-CAB-ANK-TC10-001');
final item = await repo.byBarcode('8961234567890');
await repo.recordStockCount('ACC-CAB-ANK-TC10-001', 18, 'evening count');
final reorder = await repo.reorderListBySupplier();
await repo.applyCatalogUpdate(newItems, '1.1.0'); // safe update
```

Search details (`catalog_search.dart`): queries are normalised
(lowercase, spaces/hyphens stripped, Roman-Urdu synonym map —
`cabel→cable`, `carger→charger`, `glas→glass`, `kover→cover`,
`hansfree→handsfree`, `airbuds→earbuds`, `pawar→power`, …), matched
token-by-token over name/brand/category/SKU/model, ranked exact-token
first. `"type c cabel"` finds Type-C cables.

## Testing

```bash
cd mobile_app
dart run build_runner build        # generate catalog_database.g.dart first
flutter test test/catalog_test.dart
```

Tests cover: idempotent seed (same items twice → no duplicates),
update preserves stock + custom items, barcode link → lookup,
bulk stock-in atomicity, CSV import matching (SKU, then normalised
name), search < 300 ms over 5,000 items, model JSON round-trip.

## Testing idempotency in psql

```sql
-- Run the migration twice; the second run must change nothing.
\i database/migrations/001_accessories_catalog.sql
SELECT COUNT(*) FROM catalog_items;            -- 1726
\i database/migrations/001_accessories_catalog.sql
SELECT COUNT(*) FROM catalog_items;            -- still 1726
SELECT COUNT(*) FROM catalog_stock;            -- 1726 (one row per item)
SELECT version, item_count FROM catalog_versions;
-- Stock-in, then re-run: quantities must be untouched.
UPDATE catalog_stock SET quantity = 10 WHERE sku = 'ACC-CHG-ANK-25W-001';
\i database/migrations/001_accessories_catalog.sql
SELECT quantity FROM catalog_stock WHERE sku = 'ACC-CHG-ANK-25W-001'; -- 10
```
