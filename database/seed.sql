-- ============================================================================
-- Baba Farid Mobiles — Seed Data (Module 9)
-- Shop: Baba Farid Mobiles, Jamal Chowk, Depalpur Road, Pakpattan
-- Contacts: Naeem Ahmad +92 302 4988560 · Anas Zaheer +92 329 9966771
-- Email: baba.farid.mobiles.bfw@gmail.com · Currency: PKR (whole rupees)
-- ============================================================================
-- HOW TO RUN (PostgreSQL 16):
--   createdb shopdb
--   psql -d shopdb -f database/schema.sql
--   psql -d shopdb -f database/seed.sql
-- The file is IDEMPOTENT: every INSERT uses ON CONFLICT DO NOTHING with
-- fixed UUIDs, so re-running it adds nothing twice. The branch and roles
-- are created by schema.sql; this file only references them (by name) and
-- never re-inserts them, so no duplicate branch/role rows can appear.
--
-- CONSISTENCY (verified by hand — see the checks at the end of the file):
--   * 30 IMEI items: 5 sold (one per sale INV-000001..INV-000005), 25 available.
--     Every IMEI referenced by a sale has status='sold' + sold_sale_id set.
--   * Accessory quantities are POST-SALE on-hand figures:
--     purchased qty minus sold qty (glass: 120 bought, 1 sold, 1 returned = 120).
--   * Every sale's subtotal/discount/grand_total/paid/balance is the exact sum
--     of its sale_items; profit = total - purchase_cost * quantity per item.
--   * Ledger balances are running balances: customer debit = udhaar added,
--     credit = payment received; supplier credit = payable added,
--     debit = payment made. balance_after is the amount still owed after
--     that row. Supplier payables: Hassan Mobile Traders 244500,
--     Bilal Electronics 157500. Customer udhaar: Bilal Hussain 14000,
--     Usman Ghani 24000, Muhammad Asif 38000, Hassan Ali 5000, Ali Hamza 15000.
--   * Purchases: PUR-001 451000 paid in full; PUR-002 457500, paid 300000;
--     PUR-003 944500, paid 700000.
--   * All money is whole PKR integers (NUMERIC(12,0)) — no paisa anywhere.
--
-- DEFAULT LOGINS (CHANGE AFTER FIRST LOGIN — see the warning below):
--   admin    / admin123    (Owner)    — Anas Zaheer
--   manager  / manager123  (Manager)  — Naeem Ahmad
--   cashier  / cashier123  (Cashier)  — Bilal Ahmed
-- Passwords are real bcrypt hashes (cost 12), generated with bcryptjs.
-- They are DEMO passwords only. After the first login, go to
-- Settings -> Users and set strong passwords; never use these in production.
--
-- NOTE ON LOYALTY POINTS: the schema (database/schema.sql) has no
-- loyalty_points column on customers — loyalty is a DECISIONS.md rule
-- (1 point per Rs 100, 100 points = Rs 100 discount) that is tracked by
-- the app, not stored as a column. This seed therefore does NOT invent a
-- loyalty column; customer value is shown through opening_balance and
-- the ledger instead.
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. ROLES — schema.sql already inserts these three rows; this is a no-op
--    on a normal run and only fills them in if schema.sql was skipped.
-- ---------------------------------------------------------------------------
INSERT INTO roles (name, description, permissions) VALUES
  ('owner', 'Full access: everything including profit and settings',
   '{"sales.create": true, "sales.edit": true, "sales.cancel": true, "cost.view": true, "reports.profit": true, "settings.edit": true, "users.manage": true}'::jsonb),
  ('manager', 'Sales, purchases, stock, reports. No profit editing, no settings.',
   '{"sales.create": true, "sales.edit": true, "sales.cancel": false, "cost.view": true, "reports.profit": true, "settings.edit": false, "users.manage": false}'::jsonb),
  ('cashier', 'Create bills only. No cost price visibility.',
   '{"sales.create": true, "sales.edit": false, "sales.cancel": false, "cost.view": false, "reports.profit": false, "settings.edit": false, "users.manage": false}'::jsonb)
ON CONFLICT (name) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. USERS — branch and role are looked up by name (created by schema.sql).
--    bcrypt cost 12. !!! CHANGE THESE PASSWORDS AFTER FIRST LOGIN !!!
--    admin/admin123, manager/manager123, cashier/cashier123
-- ---------------------------------------------------------------------------
INSERT INTO users (id, branch_id, role_id, name, phone, email, password_hash) VALUES
  ('10000000-0000-4000-8000-000000000001',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   (SELECT id FROM roles WHERE name = 'owner'),
   'Anas Zaheer', '+923299966771', 'baba.farid.mobiles.bfw@gmail.com',
   '$2b$12$VQ1bpusHB/iEANXfbOgLY.HeeotEqn/l0f6O.tBwfIzy64U7EuqiO'), -- admin123
  ('10000000-0000-4000-8000-000000000002',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   (SELECT id FROM roles WHERE name = 'manager'),
   'Naeem Ahmad', '+923024988560', NULL,
   '$2b$12$AUFgO3mlHKnxnk8cqMSamu1.p7nrK.g1tUIocTzE7bRiGoggVtE/2'), -- manager123
  ('10000000-0000-4000-8000-000000000003',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   (SELECT id FROM roles WHERE name = 'cashier'),
   'Bilal Ahmed', '+923001234567', NULL,
   '$2b$12$HeixCwJYv5WfT81k2LFZpeNPxPARDGuAW7vF324HKida6moTDRdHS')  -- cashier123
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 3. SETTINGS — schema.sql already sets the shop.* keys; re-inserting them
--    is a no-op. The theme/language/owner keys are added here.
-- ---------------------------------------------------------------------------
INSERT INTO settings (key, value) VALUES
  ('shop.name', '"Baba Farid Mobiles"'::jsonb),
  ('shop.address', '"Jamal Chowk, Depalpur Road, Pakpattan"'::jsonb),
  ('shop.phone', '"+92 329 9966771"'::jsonb),
  ('shop.phone2', '"+92 302 4988560"'::jsonb),
  ('shop.email', '"baba.farid.mobiles.bfw@gmail.com"'::jsonb),
  ('shop.currency', '"PKR"'::jsonb),
  ('tax.enabled', 'false'::jsonb),
  ('tax.rate', '0'::jsonb),
  ('shop.owner', '"Naeem Ahmad"'::jsonb),
  ('shop.theme', '"hacker"'::jsonb),
  ('shop.language', '"en"'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 4. CATEGORIES (7)
-- ---------------------------------------------------------------------------
INSERT INTO categories (id, name, type, parent_id) VALUES
  ('11000000-0000-4000-8000-000000000001', 'Mobile Phones', 'phone', NULL),
  ('11000000-0000-4000-8000-000000000002', 'Accessories', 'accessory', NULL),
  ('11000000-0000-4000-8000-000000000003', 'Chargers', 'accessory', '11000000-0000-4000-8000-000000000002'),
  ('11000000-0000-4000-8000-000000000004', 'Audio', 'accessory', '11000000-0000-4000-8000-000000000002'),
  ('11000000-0000-4000-8000-000000000005', 'Covers & Glass', 'accessory', '11000000-0000-4000-8000-000000000002'),
  ('11000000-0000-4000-8000-000000000006', 'Power', 'accessory', '11000000-0000-4000-8000-000000000002'),
  ('11000000-0000-4000-8000-000000000007', 'Storage', 'accessory', '11000000-0000-4000-8000-000000000002')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5. BRANDS (15)
-- ---------------------------------------------------------------------------
INSERT INTO brands (id, name) VALUES
  ('12000000-0000-4000-8000-000000000001', 'Samsung'),
  ('12000000-0000-4000-8000-000000000002', 'Infinix'),
  ('12000000-0000-4000-8000-000000000003', 'Tecno'),
  ('12000000-0000-4000-8000-000000000004', 'Xiaomi'),
  ('12000000-0000-4000-8000-000000000005', 'Vivo'),
  ('12000000-0000-4000-8000-000000000006', 'Oppo'),
  ('12000000-0000-4000-8000-000000000007', 'Realme'),
  ('12000000-0000-4000-8000-000000000008', 'Apple'),
  ('12000000-0000-4000-8000-000000000009', 'Nokia'),
  ('12000000-0000-4000-8000-000000000010', 'itel'),
  ('12000000-0000-4000-8000-000000000011', 'Generic'),
  ('12000000-0000-4000-8000-000000000012', 'Oraimo'),
  ('12000000-0000-4000-8000-000000000013', 'Anker'),
  ('12000000-0000-4000-8000-000000000014', 'Baseus'),
  ('12000000-0000-4000-8000-000000000015', 'SanDisk')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 6. PRODUCTS (21: 12 phones + 9 accessories)
--    Brand/category are referenced by subquery on name so the file works
--    even if the brand/category UUIDs differ on another database.
-- ---------------------------------------------------------------------------
INSERT INTO products (id, brand_id, category_id, type, name, description, barcode) VALUES
  ('13000000-0000-4000-8000-000000000001', (SELECT id FROM brands WHERE name='Samsung'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Samsung Galaxy A16', '6.7" Super AMOLED, 5000mAh, 50MP camera', NULL),
  ('13000000-0000-4000-8000-000000000002', (SELECT id FROM brands WHERE name='Samsung'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Samsung Galaxy A06', '6.7" display, 5000mAh, budget everyday phone', NULL),
  ('13000000-0000-4000-8000-000000000003', (SELECT id FROM brands WHERE name='Infinix'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Infinix Hot 50', '6.78" 120Hz display, Helio G100, 5000mAh', NULL),
  ('13000000-0000-4000-8000-000000000004', (SELECT id FROM brands WHERE name='Infinix'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Infinix Note 40', '6.78" AMOLED, 108MP OIS camera, 45W fast charging', NULL),
  ('13000000-0000-4000-8000-000000000005', (SELECT id FROM brands WHERE name='Tecno'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Tecno Spark 30', '6.78" 90Hz display, 5000mAh, 64MP camera', NULL),
  ('13000000-0000-4000-8000-000000000006', (SELECT id FROM brands WHERE name='Tecno'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Tecno Camon 30', '6.78" AMOLED, 50MP OIS camera, 70W charging', NULL),
  ('13000000-0000-4000-8000-000000000007', (SELECT id FROM brands WHERE name='Xiaomi'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Redmi Note 13', '6.67" AMOLED 120Hz, 108MP camera, 5000mAh', NULL),
  ('13000000-0000-4000-8000-000000000008', (SELECT id FROM brands WHERE name='Vivo'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Vivo Y28', '6.68" 90Hz display, 6000mAh battery, 50MP camera', NULL),
  ('13000000-0000-4000-8000-000000000009', (SELECT id FROM brands WHERE name='Oppo'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Oppo A18', '6.56" 90Hz display, 5000mAh, 8MP camera', NULL),
  ('13000000-0000-4000-8000-000000000010', (SELECT id FROM brands WHERE name='itel'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'itel A70', '6.6" display, 5000mAh, budget smartphone', NULL),
  ('13000000-0000-4000-8000-000000000011', (SELECT id FROM brands WHERE name='Apple'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Apple iPhone 13', 'Used, 128GB, A15 Bionic, 6.1" Super Retina XDR', NULL),
  ('13000000-0000-4000-8000-000000000012', (SELECT id FROM brands WHERE name='Nokia'), (SELECT id FROM categories WHERE name='Mobile Phones'), 'phone', 'Nokia 105', 'Feature phone, FM radio, long battery backup', NULL),
  ('13000000-0000-4000-8000-000000000013', (SELECT id FROM brands WHERE name='Oraimo'), (SELECT id FROM categories WHERE name='Chargers'), 'accessory', 'Oraimo Fast Charger 25W', '25W USB-C fast charger with cable', 'ORM-CHG-25W'),
  ('13000000-0000-4000-8000-000000000014', (SELECT id FROM brands WHERE name='Anker'), (SELECT id FROM categories WHERE name='Chargers'), 'accessory', 'Anker USB-C Cable 1m', 'Braided USB-C to USB-C cable, 1 metre', 'ANK-CAB-C1M'),
  ('13000000-0000-4000-8000-000000000015', (SELECT id FROM brands WHERE name='Oraimo'), (SELECT id FROM categories WHERE name='Audio'), 'accessory', 'Oraimo FreePods Lite', 'True wireless earbuds, ENC mic, 30h playtime', 'ORM-PODS-LITE'),
  ('13000000-0000-4000-8000-000000000016', (SELECT id FROM brands WHERE name='Baseus'), (SELECT id FROM categories WHERE name='Audio'), 'accessory', 'Baseus Encok W04', 'True wireless earbuds, Bluetooth 5.3', 'BS-W04'),
  ('13000000-0000-4000-8000-000000000017', (SELECT id FROM brands WHERE name='Generic'), (SELECT id FROM categories WHERE name='Covers & Glass'), 'accessory', 'Galaxy A16 Back Cover', 'Soft silicone back cover for Galaxy A16', 'COV-A16-BLK'),
  ('13000000-0000-4000-8000-000000000018', (SELECT id FROM brands WHERE name='Generic'), (SELECT id FROM categories WHERE name='Covers & Glass'), 'accessory', 'Tempered Glass 9H', '9H tempered glass screen protector, universal fit', 'GLS-9H-UNI'),
  ('13000000-0000-4000-8000-000000000019', (SELECT id FROM brands WHERE name='Oraimo'), (SELECT id FROM categories WHERE name='Power'), 'accessory', 'Oraimo Power Bank 20000mAh', '20000mAh power bank, 22.5W fast charging', 'ORM-PB-20K'),
  ('13000000-0000-4000-8000-000000000020', (SELECT id FROM brands WHERE name='SanDisk'), (SELECT id FROM categories WHERE name='Storage'), 'accessory', 'SanDisk microSD 64GB', '64GB microSD card, Class 10, with adapter', 'SD-64GB'),
  ('13000000-0000-4000-8000-000000000021', (SELECT id FROM brands WHERE name='Generic'), (SELECT id FROM categories WHERE name='Accessories'), 'accessory', 'Smart Watch X9 Ultra', 'Bluetooth calling smartwatch, 2.09" display', 'SW-X9-ULTRA')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 7. PRODUCT VARIANTS (26: 17 phone variants + 9 accessory variants)
--    Phones: quantity = 0 (stock is counted from imei_items, not quantity).
--    Accessories: quantity = ON-HAND after the seed sales below
--    (purchased minus sold; glass 120 = 120 bought - 1 sold + 1 returned).
-- ---------------------------------------------------------------------------
INSERT INTO product_variants (id, product_id, name, color, storage_gb, ram_gb, condition, pta_status, barcode, purchase_price, sale_price, min_price, warranty_months, quantity, low_stock_threshold) VALUES
  ('14000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000001', '8GB / 128GB · Black', 'Black', 128, 8, 'new', 'approved', NULL, 48500, 54000, 52000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000001', '8GB / 256GB · Green', 'Green', 256, 8, 'new', 'approved', NULL, 54000, 60000, 57500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000002', '4GB / 64GB · Blue', 'Blue', 64, 4, 'new', 'approved', NULL, 28500, 32500, 31000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000004', '13000000-0000-4000-8000-000000000003', '8GB / 128GB · Black', 'Black', 128, 8, 'new', 'approved', NULL, 37500, 42000, 40000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000005', '13000000-0000-4000-8000-000000000003', '8GB / 256GB · Blue (Pro)', 'Blue', 256, 8, 'new', 'approved', NULL, 43000, 48000, 46000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000006', '13000000-0000-4000-8000-000000000004', '8GB / 256GB · Gold', 'Gold', 256, 8, 'new', 'approved', NULL, 58500, 65000, 62500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000007', '13000000-0000-4000-8000-000000000005', '8GB / 128GB · White', 'White', 128, 8, 'new', 'approved', NULL, 34500, 39000, 37500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000008', '13000000-0000-4000-8000-000000000005', '4GB / 128GB · Black', 'Black', 128, 4, 'new', 'approved', NULL, 31000, 35000, 33500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000009', '13000000-0000-4000-8000-000000000006', '8GB / 256GB · Black', 'Black', 256, 8, 'new', 'approved', NULL, 68000, 75000, 72000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000010', '13000000-0000-4000-8000-000000000007', '8GB / 256GB · Blue', 'Blue', 256, 8, 'new', 'approved', NULL, 62000, 69000, 66500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000011', '13000000-0000-4000-8000-000000000007', '8GB / 128GB · Black', 'Black', 128, 8, 'new', 'approved', NULL, 56000, 63000, 60000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000012', '13000000-0000-4000-8000-000000000008', '8GB / 128GB · Green', 'Green', 128, 8, 'new', 'approved', NULL, 52000, 58000, 55500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000013', '13000000-0000-4000-8000-000000000008', '6GB / 128GB · Black', 'Black', 128, 6, 'new', 'approved', NULL, 47000, 53000, 50500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000014', '13000000-0000-4000-8000-000000000009', '4GB / 128GB · Black', 'Black', 128, 4, 'new', 'approved', NULL, 36000, 40500, 39000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000015', '13000000-0000-4000-8000-000000000010', '4GB / 128GB · Silver', 'Silver', 128, 4, 'new', 'approved', NULL, 22500, 26000, 24500, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000016', '13000000-0000-4000-8000-000000000011', '128GB · Midnight', 'Midnight', 128, 4, 'used', 'non_pta', NULL, 135000, 152000, 145000, 3, 0, 1),
  ('14000000-0000-4000-8000-000000000017', '13000000-0000-4000-8000-000000000012', 'Dual SIM · Black', 'Black', NULL, NULL, 'new', 'approved', NULL, 4500, 5500, 5000, 12, 0, 2),
  ('14000000-0000-4000-8000-000000000018', '13000000-0000-4000-8000-000000000013', '25W USB-C · Black', 'Black', NULL, NULL, 'new', 'not_applicable', 'ORM-CHG-25W', 1400, 2000, 1700, 6, 49, 10),
  ('14000000-0000-4000-8000-000000000019', '13000000-0000-4000-8000-000000000014', '1m USB-C · Black', 'Black', NULL, NULL, 'new', 'not_applicable', 'ANK-CAB-C1M', 900, 1400, 1200, 6, 59, 15),
  ('14000000-0000-4000-8000-000000000020', '13000000-0000-4000-8000-000000000015', 'FreePods Lite · White', 'White', NULL, NULL, 'new', 'not_applicable', 'ORM-PODS-LITE', 3800, 5500, 4800, 6, 19, 5),
  ('14000000-0000-4000-8000-000000000021', '13000000-0000-4000-8000-000000000016', 'Encok W04 · Black', 'Black', NULL, NULL, 'new', 'not_applicable', 'BS-W04', 5200, 7500, 6800, 6, 12, 5),
  ('14000000-0000-4000-8000-000000000022', '13000000-0000-4000-8000-000000000017', 'Back Cover · Black', 'Black', NULL, NULL, 'new', 'not_applicable', 'COV-A16-BLK', 450, 800, 650, 0, 39, 10),
  ('14000000-0000-4000-8000-000000000023', '13000000-0000-4000-8000-000000000018', 'Tempered Glass 9H', NULL, NULL, NULL, 'new', 'not_applicable', 'GLS-9H-UNI', 180, 400, 300, 0, 120, 20),
  ('14000000-0000-4000-8000-000000000024', '13000000-0000-4000-8000-000000000019', '20000mAh · Black', 'Black', NULL, NULL, 'new', 'not_applicable', 'ORM-PB-20K', 4200, 6000, 5400, 6, 15, 5),
  ('14000000-0000-4000-8000-000000000025', '13000000-0000-4000-8000-000000000020', '64GB · Class 10', NULL, NULL, NULL, 'new', 'not_applicable', 'SD-64GB', 1500, 2200, 1900, 0, 25, 8),
  ('14000000-0000-4000-8000-000000000026', '13000000-0000-4000-8000-000000000021', 'X9 Ultra · Black', 'Black', NULL, NULL, 'new', 'not_applicable', 'SW-X9-ULTRA', 5500, 8000, 7200, 6, 10, 3)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 8. CUSTOMERS (10) — opening_balance is old udhaar carried into the shop.
--    Hassan Ali 5000 and Ali Hamza 15000 have opening udhaar; the other
--    balances (Bilal 14000, Usman 24000, Asif 38000) come from the sales
--    below and are tracked in ledger_entries, not here.
-- ---------------------------------------------------------------------------
INSERT INTO customers (id, name, phone, cnic, address, opening_balance) VALUES
  ('16000000-0000-4000-8000-000000000001', 'Ahmed Raza', '03012345678', '35202-1234567-1', 'Mohalla Farid Nagar, Pakpattan', 0),
  ('16000000-0000-4000-8000-000000000002', 'Bilal Hussain', '03023456789', '35202-2345678-2', 'Chak 45/EB, Arifwala Road, Pakpattan', 0),
  ('16000000-0000-4000-8000-000000000003', 'Usman Ghani', '03034567890', NULL, 'Depalpur Road, Pakpattan', 0),
  ('16000000-0000-4000-8000-000000000004', 'Muhammad Asif', '03045678901', '35202-3456789-3', 'Jamal Chowk, Pakpattan', 0),
  ('16000000-0000-4000-8000-000000000005', 'Hassan Ali', '03056789012', NULL, 'Basti Maluk Shah, Pakpattan', 5000),
  ('16000000-0000-4000-8000-000000000006', 'Fatima Zahra', '03067890123', NULL, 'Mohalla Islam Nagar, Pakpattan', 0),
  ('16000000-0000-4000-8000-000000000007', 'Ali Hamza', '03078901234', '35202-4567890-4', 'Village 12/SP, Pakpattan', 15000),
  ('16000000-0000-4000-8000-000000000008', 'Ayesha Khan', '03089012345', NULL, 'Farid Town, Pakpattan', 0),
  ('16000000-0000-4000-8000-000000000009', 'Muhammad Umar', '03090123456', NULL, 'Main Bazaar, Pakpattan', 0),
  ('16000000-0000-4000-8000-000000000010', 'Zainab Bibi', '03101234567', NULL, 'Chak 78/D, Pakpattan', 0)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 9. SUPPLIERS (2) — Lahore mobile-market wholesalers.
--    Payables come from the purchases below: Hassan Mobile Traders 244500,
--    Bilal Electronics 157500 (opening_payable is 0 for both).
-- ---------------------------------------------------------------------------
INSERT INTO suppliers (id, name, phone, address, opening_payable) VALUES
  ('17000000-0000-4000-8000-000000000001', 'Hassan Mobile Traders', '03217654321', 'Shop 12, Hall Road, Lahore', 0),
  ('17000000-0000-4000-8000-000000000002', 'Bilal Electronics', '03009876543', 'Shop 5, Hafeez Centre, Gulberg III, Lahore', 0)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 10. PURCHASES (3)
--     PUR-001: 10 phones, 451000, paid in full (2026-11-02).
--     PUR-002: accessories, 457500, paid 300000, balance 157500 (2026-11-05).
--     PUR-003: 20 phones, 944500, paid 700000, balance 244500 (2026-11-09).
-- ---------------------------------------------------------------------------
INSERT INTO purchases (id, supplier_id, branch_id, user_id, supplier_invoice_no, purchase_date, subtotal, discount, grand_total, paid_amount, balance_due, status, notes, client_uuid) VALUES
  ('18000000-0000-4000-8000-000000000001', '17000000-0000-4000-8000-000000000001',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '10000000-0000-4000-8000-000000000002', 'HMT-2026-1102', '2026-11-02 10:30:00+05',
   451000, 0, 451000, 451000, 0, 'received', '10 phones — Galaxy A16 x3, Hot 50 x3, Spark 30 x2, Redmi Note 13 x2',
   '41000000-0000-4000-8000-000000000001'),
  ('18000000-0000-4000-8000-000000000002', '17000000-0000-4000-8000-000000000002',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '10000000-0000-4000-8000-000000000002', 'BE-2026-1105', '2026-11-05 12:00:00+05',
   457500, 0, 457500, 300000, 157500, 'received', 'Accessories lot — chargers, cables, earbuds, covers, glass, power banks, memory cards, smart watches',
   '41000000-0000-4000-8000-000000000002'),
  ('18000000-0000-4000-8000-000000000003', '17000000-0000-4000-8000-000000000001',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '10000000-0000-4000-8000-000000000002', 'HMT-2026-1109', '2026-11-09 11:15:00+05',
   944500, 0, 944500, 700000, 244500, 'received', '20 phones incl. used iPhone 13 (Non-PTA) and Nokia 105',
   '41000000-0000-4000-8000-000000000003')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 11. PURCHASE ITEMS (39 rows: 10 + 9 + 20)
--     One row per phone IMEI (imei1 matches imei_items below); one row per
--     accessory with its quantity. Row totals add up to each purchase total.
-- ---------------------------------------------------------------------------
INSERT INTO purchase_items (id, purchase_id, product_id, variant_id, imei1, imei2, quantity, unit_cost, total) VALUES
  -- PUR-001 (10 phones)
  ('19000000-0000-4000-8000-000000000001', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000001', '860123456789011', '860123456789051', 1, 48500, 48500),
  ('19000000-0000-4000-8000-000000000002', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000001', '860123456789012', NULL, 1, 48500, 48500),
  ('19000000-0000-4000-8000-000000000003', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000001', '860123456789013', NULL, 1, 48500, 48500),
  ('19000000-0000-4000-8000-000000000004', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000004', '860234567890114', '860234567890154', 1, 37500, 37500),
  ('19000000-0000-4000-8000-000000000005', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000004', '860234567890115', NULL, 1, 37500, 37500),
  ('19000000-0000-4000-8000-000000000006', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000004', '860234567890116', NULL, 1, 37500, 37500),
  ('19000000-0000-4000-8000-000000000007', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000005', '14000000-0000-4000-8000-000000000007', '860345678901217', '860345678901257', 1, 34500, 34500),
  ('19000000-0000-4000-8000-000000000008', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000005', '14000000-0000-4000-8000-000000000007', '860345678901218', NULL, 1, 34500, 34500),
  ('19000000-0000-4000-8000-000000000009', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000007', '14000000-0000-4000-8000-000000000010', '860456789012319', '860456789012359', 1, 62000, 62000),
  ('19000000-0000-4000-8000-000000000010', '18000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000007', '14000000-0000-4000-8000-000000000010', '860456789012320', NULL, 1, 62000, 62000),
  -- PUR-002 (9 accessory lines)
  ('19000000-0000-4000-8000-000000000011', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000013', '14000000-0000-4000-8000-000000000018', NULL, NULL, 50, 1400, 70000),
  ('19000000-0000-4000-8000-000000000012', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000014', '14000000-0000-4000-8000-000000000019', NULL, NULL, 60, 900, 54000),
  ('19000000-0000-4000-8000-000000000013', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000015', '14000000-0000-4000-8000-000000000020', NULL, NULL, 20, 3800, 76000),
  ('19000000-0000-4000-8000-000000000014', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000016', '14000000-0000-4000-8000-000000000021', NULL, NULL, 12, 5200, 62400),
  ('19000000-0000-4000-8000-000000000015', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000017', '14000000-0000-4000-8000-000000000022', NULL, NULL, 40, 450, 18000),
  ('19000000-0000-4000-8000-000000000016', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000018', '14000000-0000-4000-8000-000000000023', NULL, NULL, 120, 180, 21600),
  ('19000000-0000-4000-8000-000000000017', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000019', '14000000-0000-4000-8000-000000000024', NULL, NULL, 15, 4200, 63000),
  ('19000000-0000-4000-8000-000000000018', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000020', '14000000-0000-4000-8000-000000000025', NULL, NULL, 25, 1500, 37500),
  ('19000000-0000-4000-8000-000000000019', '18000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000021', '14000000-0000-4000-8000-000000000026', NULL, NULL, 10, 5500, 55000),
  -- PUR-003 (20 phones)
  ('19000000-0000-4000-8000-000000000020', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000002', '14000000-0000-4000-8000-000000000003', '860567890123421', NULL, 1, 28500, 28500),
  ('19000000-0000-4000-8000-000000000021', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000002', '14000000-0000-4000-8000-000000000003', '860567890123422', NULL, 1, 28500, 28500),
  ('19000000-0000-4000-8000-000000000022', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000004', '14000000-0000-4000-8000-000000000006', '860678901234523', NULL, 1, 58500, 58500),
  ('19000000-0000-4000-8000-000000000023', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000004', '14000000-0000-4000-8000-000000000006', '860678901234524', NULL, 1, 58500, 58500),
  ('19000000-0000-4000-8000-000000000024', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000006', '14000000-0000-4000-8000-000000000009', '860789012345625', NULL, 1, 68000, 68000),
  ('19000000-0000-4000-8000-000000000025', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000006', '14000000-0000-4000-8000-000000000009', '860789012345626', NULL, 1, 68000, 68000),
  ('19000000-0000-4000-8000-000000000026', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000008', '14000000-0000-4000-8000-000000000012', '860890123456727', '860890123456767', 1, 52000, 52000),
  ('19000000-0000-4000-8000-000000000027', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000008', '14000000-0000-4000-8000-000000000012', '860890123456728', NULL, 1, 52000, 52000),
  ('19000000-0000-4000-8000-000000000028', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000009', '14000000-0000-4000-8000-000000000014', '860901234567829', NULL, 1, 36000, 36000),
  ('19000000-0000-4000-8000-000000000029', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000009', '14000000-0000-4000-8000-000000000014', '860901234567830', NULL, 1, 36000, 36000),
  ('19000000-0000-4000-8000-000000000030', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000010', '14000000-0000-4000-8000-000000000015', '861012345678931', NULL, 1, 22500, 22500),
  ('19000000-0000-4000-8000-000000000031', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000010', '14000000-0000-4000-8000-000000000015', '861012345678932', NULL, 1, 22500, 22500),
  ('19000000-0000-4000-8000-000000000032', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000011', '14000000-0000-4000-8000-000000000016', '356123456789013', '356123456789023', 1, 135000, 135000),
  ('19000000-0000-4000-8000-000000000033', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000012', '14000000-0000-4000-8000-000000000017', '359123456789014', NULL, 1, 4500, 4500),
  ('19000000-0000-4000-8000-000000000034', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000002', '860123456789015', NULL, 1, 54000, 54000),
  ('19000000-0000-4000-8000-000000000035', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000007', '14000000-0000-4000-8000-000000000011', '860456789012316', NULL, 1, 56000, 56000),
  ('19000000-0000-4000-8000-000000000036', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000008', '14000000-0000-4000-8000-000000000013', '860890123456729', NULL, 1, 47000, 47000),
  ('19000000-0000-4000-8000-000000000037', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000005', '14000000-0000-4000-8000-000000000008', '860345678901219', NULL, 1, 31000, 31000),
  ('19000000-0000-4000-8000-000000000038', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000005', '860234567890117', NULL, 1, 43000, 43000),
  ('19000000-0000-4000-8000-000000000039', '18000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000005', '860234567890118', NULL, 1, 43000, 43000)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 12. SALES (5 bills, INV-000001..INV-000005)
--     INV-000001: paid in full (54000); glass later returned -> status
--       'partially_returned' (see sale_returns, section 15).
--     INV-000002: partial — 20000 cash at sale + 10000 JazzCash later
--       = paid 30000, balance 14000 (udhaar, Bilal Hussain).
--     INV-000003: installment sale — 15000 down, 3 x 8000 (Usman Ghani).
--     INV-000004: walk-in customer, paid in full (75000).
--     INV-000005: installment sale — 20000 down, 4 x 9500 (Muhammad Asif).
--     paid_amount + balance_due = grand_total on every row.
-- ---------------------------------------------------------------------------
INSERT INTO sales (id, invoice_no, branch_id, customer_id, customer_name, customer_phone, user_id, sale_date, subtotal, discount_amount, discount_percent, tax_amount, grand_total, paid_amount, balance_due, payment_method, payment_status, status, notes, client_uuid) VALUES
  ('20000000-0000-4000-8000-000000000001', 'INV-000001',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '16000000-0000-4000-8000-000000000001', 'Ahmed Raza', '03012345678',
   '10000000-0000-4000-8000-000000000003', '2026-11-10 18:20:00+05',
   55200, 1200, 0, 0, 54000, 54000, 0, 'cash', 'paid', 'partially_returned',
   'Galaxy A16 + glass + cover. Rs 1200 discount. Glass returned 16 Nov (refund Rs 400).',
   '40000000-0000-4000-8000-000000000001'),
  ('20000000-0000-4000-8000-000000000002', 'INV-000002',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '16000000-0000-4000-8000-000000000002', 'Bilal Hussain', '03023456789',
   '10000000-0000-4000-8000-000000000003', '2026-11-11 13:05:00+05',
   44000, 0, 0, 0, 44000, 30000, 14000, 'partial', 'partial', 'completed',
   'Hot 50 + charger. Rs 20000 cash at sale, Rs 10000 JazzCash on 14 Nov. Balance Rs 14000 udhaar.',
   '40000000-0000-4000-8000-000000000002'),
  ('20000000-0000-4000-8000-000000000003', 'INV-000003',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '16000000-0000-4000-8000-000000000003', 'Usman Ghani', '03034567890',
   '10000000-0000-4000-8000-000000000003', '2026-10-15 17:40:00+05',
   39000, 0, 0, 0, 39000, 15000, 24000, 'partial', 'partial', 'completed',
   'Spark 30 on installments: Rs 15000 down, 3 x Rs 8000. First installment overdue (due 15 Nov).',
   '40000000-0000-4000-8000-000000000003'),
  ('20000000-0000-4000-8000-000000000004', 'INV-000004',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   NULL, 'Walk-in Customer', NULL,
   '10000000-0000-4000-8000-000000000003', '2026-11-13 19:10:00+05',
   75900, 900, 0, 0, 75000, 75000, 0, 'cash', 'paid', 'completed',
   'Redmi Note 13 + earbuds + cable. Rs 900 discount.',
   '40000000-0000-4000-8000-000000000004'),
  ('20000000-0000-4000-8000-000000000005', 'INV-000005',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '16000000-0000-4000-8000-000000000004', 'Muhammad Asif', '03045678901',
   '10000000-0000-4000-8000-000000000003', '2026-11-14 12:30:00+05',
   58000, 0, 0, 0, 58000, 20000, 38000, 'partial', 'partial', 'completed',
   'Vivo Y28 on installments: Rs 20000 down, 4 x Rs 9500.',
   '40000000-0000-4000-8000-000000000005')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 13. IMEI ITEMS (30) — one row per phone bought in PUR-001 + PUR-003.
--     5 are SOLD (sold_sale_id points at the sale that sold them);
--     25 are AVAILABLE. Warranty runs 12 months from purchase
--     (3 months for the used iPhone 13). A sold IMEI can never be sold
--     again unless its sale is returned — the app enforces status='available'.
-- ---------------------------------------------------------------------------
INSERT INTO imei_items (id, product_id, variant_id, imei1, imei2, status, purchase_id, purchase_price, sale_price, sold_sale_id, warranty_start, warranty_end) VALUES
  ('15000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000001', '860123456789011', '860123456789051', 'sold',      '18000000-0000-4000-8000-000000000001', 48500, 54000, '20000000-0000-4000-8000-000000000001', '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000001', '860123456789012', NULL, 'available', '18000000-0000-4000-8000-000000000001', 48500, 54000, NULL, '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000001', '860123456789013', NULL, 'available', '18000000-0000-4000-8000-000000000001', 48500, 54000, NULL, '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000004', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000002', '860123456789015', NULL, 'available', '18000000-0000-4000-8000-000000000003', 54000, 60000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000005', '13000000-0000-4000-8000-000000000002', '14000000-0000-4000-8000-000000000003', '860567890123421', NULL, 'available', '18000000-0000-4000-8000-000000000003', 28500, 32500, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000006', '13000000-0000-4000-8000-000000000002', '14000000-0000-4000-8000-000000000003', '860567890123422', NULL, 'available', '18000000-0000-4000-8000-000000000003', 28500, 32500, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000007', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000004', '860234567890114', '860234567890154', 'sold',      '18000000-0000-4000-8000-000000000001', 37500, 42000, '20000000-0000-4000-8000-000000000002', '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000008', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000004', '860234567890115', NULL, 'available', '18000000-0000-4000-8000-000000000001', 37500, 42000, NULL, '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000009', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000004', '860234567890116', NULL, 'available', '18000000-0000-4000-8000-000000000001', 37500, 42000, NULL, '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000010', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000005', '860234567890117', NULL, 'available', '18000000-0000-4000-8000-000000000003', 43000, 48000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000011', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000005', '860234567890118', NULL, 'available', '18000000-0000-4000-8000-000000000003', 43000, 48000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000012', '13000000-0000-4000-8000-000000000004', '14000000-0000-4000-8000-000000000006', '860678901234523', NULL, 'available', '18000000-0000-4000-8000-000000000003', 58500, 65000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000013', '13000000-0000-4000-8000-000000000004', '14000000-0000-4000-8000-000000000006', '860678901234524', NULL, 'available', '18000000-0000-4000-8000-000000000003', 58500, 65000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000014', '13000000-0000-4000-8000-000000000005', '14000000-0000-4000-8000-000000000007', '860345678901217', '860345678901257', 'sold',      '18000000-0000-4000-8000-000000000001', 34500, 39000, '20000000-0000-4000-8000-000000000003', '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000015', '13000000-0000-4000-8000-000000000005', '14000000-0000-4000-8000-000000000007', '860345678901218', NULL, 'available', '18000000-0000-4000-8000-000000000001', 34500, 39000, NULL, '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000016', '13000000-0000-4000-8000-000000000005', '14000000-0000-4000-8000-000000000008', '860345678901219', NULL, 'available', '18000000-0000-4000-8000-000000000003', 31000, 35000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000017', '13000000-0000-4000-8000-000000000006', '14000000-0000-4000-8000-000000000009', '860789012345625', NULL, 'available', '18000000-0000-4000-8000-000000000003', 68000, 75000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000018', '13000000-0000-4000-8000-000000000006', '14000000-0000-4000-8000-000000000009', '860789012345626', NULL, 'available', '18000000-0000-4000-8000-000000000003', 68000, 75000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000019', '13000000-0000-4000-8000-000000000007', '14000000-0000-4000-8000-000000000010', '860456789012319', '860456789012359', 'sold',      '18000000-0000-4000-8000-000000000001', 62000, 69000, '20000000-0000-4000-8000-000000000004', '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000020', '13000000-0000-4000-8000-000000000007', '14000000-0000-4000-8000-000000000010', '860456789012320', NULL, 'available', '18000000-0000-4000-8000-000000000001', 62000, 69000, NULL, '2026-11-02', '2027-11-02'),
  ('15000000-0000-4000-8000-000000000021', '13000000-0000-4000-8000-000000000007', '14000000-0000-4000-8000-000000000011', '860456789012316', NULL, 'available', '18000000-0000-4000-8000-000000000003', 56000, 63000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000022', '13000000-0000-4000-8000-000000000008', '14000000-0000-4000-8000-000000000012', '860890123456727', '860890123456767', 'sold',      '18000000-0000-4000-8000-000000000003', 52000, 58000, '20000000-0000-4000-8000-000000000005', '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000023', '13000000-0000-4000-8000-000000000008', '14000000-0000-4000-8000-000000000012', '860890123456728', NULL, 'available', '18000000-0000-4000-8000-000000000003', 52000, 58000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000024', '13000000-0000-4000-8000-000000000008', '14000000-0000-4000-8000-000000000013', '860890123456729', NULL, 'available', '18000000-0000-4000-8000-000000000003', 47000, 53000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000025', '13000000-0000-4000-8000-000000000009', '14000000-0000-4000-8000-000000000014', '860901234567829', NULL, 'available', '18000000-0000-4000-8000-000000000003', 36000, 40500, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000026', '13000000-0000-4000-8000-000000000009', '14000000-0000-4000-8000-000000000014', '860901234567830', NULL, 'available', '18000000-0000-4000-8000-000000000003', 36000, 40500, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000027', '13000000-0000-4000-8000-000000000010', '14000000-0000-4000-8000-000000000015', '861012345678931', NULL, 'available', '18000000-0000-4000-8000-000000000003', 22500, 26000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000028', '13000000-0000-4000-8000-000000000010', '14000000-0000-4000-8000-000000000015', '861012345678932', NULL, 'available', '18000000-0000-4000-8000-000000000003', 22500, 26000, NULL, '2026-11-09', '2027-11-09'),
  ('15000000-0000-4000-8000-000000000029', '13000000-0000-4000-8000-000000000011', '14000000-0000-4000-8000-000000000016', '356123456789013', '356123456789023', 'available', '18000000-0000-4000-8000-000000000003', 135000, 152000, NULL, '2026-11-09', '2027-02-09'),
  ('15000000-0000-4000-8000-000000000030', '13000000-0000-4000-8000-000000000012', '14000000-0000-4000-8000-000000000017', '359123456789014', NULL, 'available', '18000000-0000-4000-8000-000000000003', 4500, 5500, NULL, '2026-11-09', '2027-11-09')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 14. SALE ITEMS (10) — profit = total - purchase_cost * quantity.
--     Total profit across the 5 seed sales: 4870 + 5100 + 4500 + 8300 + 6000
--     = 28770 PKR. (Per-item total = unit_price * quantity - discount,
--     so item totals always sum to the sale's grand_total.)
-- ---------------------------------------------------------------------------
INSERT INTO sale_items (id, sale_id, product_id, variant_id, imei_item_id, name_snapshot, quantity, unit_price, purchase_cost, discount, total, profit) VALUES
  ('21000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000001', '14000000-0000-4000-8000-000000000001', '15000000-0000-4000-8000-000000000001', 'Samsung Galaxy A16 8GB / 128GB · Black', 1, 54000, 48500, 1200, 52800, 4300),
  ('21000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000018', '14000000-0000-4000-8000-000000000023', NULL, 'Tempered Glass 9H', 1, 400, 180, 0, 400, 220),
  ('21000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000001', '13000000-0000-4000-8000-000000000017', '14000000-0000-4000-8000-000000000022', NULL, 'Galaxy A16 Back Cover', 1, 800, 450, 0, 800, 350),
  ('21000000-0000-4000-8000-000000000004', '20000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000003', '14000000-0000-4000-8000-000000000004', '15000000-0000-4000-8000-000000000007', 'Infinix Hot 50 8GB / 128GB · Black', 1, 42000, 37500, 0, 42000, 4500),
  ('21000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000002', '13000000-0000-4000-8000-000000000013', '14000000-0000-4000-8000-000000000018', NULL, 'Oraimo Fast Charger 25W', 1, 2000, 1400, 0, 2000, 600),
  ('21000000-0000-4000-8000-000000000006', '20000000-0000-4000-8000-000000000003', '13000000-0000-4000-8000-000000000005', '14000000-0000-4000-8000-000000000007', '15000000-0000-4000-8000-000000000014', 'Tecno Spark 30 8GB / 128GB · White', 1, 39000, 34500, 0, 39000, 4500),
  ('21000000-0000-4000-8000-000000000007', '20000000-0000-4000-8000-000000000004', '13000000-0000-4000-8000-000000000007', '14000000-0000-4000-8000-000000000010', '15000000-0000-4000-8000-000000000019', 'Redmi Note 13 8GB / 256GB · Blue', 1, 69000, 62000, 900, 68100, 6100),
  ('21000000-0000-4000-8000-000000000008', '20000000-0000-4000-8000-000000000004', '13000000-0000-4000-8000-000000000015', '14000000-0000-4000-8000-000000000020', NULL, 'Oraimo FreePods Lite', 1, 5500, 3800, 0, 5500, 1700),
  ('21000000-0000-4000-8000-000000000009', '20000000-0000-4000-8000-000000000004', '13000000-0000-4000-8000-000000000014', '14000000-0000-4000-8000-000000000019', NULL, 'Anker USB-C Cable 1m', 1, 1400, 900, 0, 1400, 500),
  ('21000000-0000-4000-8000-000000000010', '20000000-0000-4000-8000-000000000005', '13000000-0000-4000-8000-000000000008', '14000000-0000-4000-8000-000000000012', '15000000-0000-4000-8000-000000000022', 'Vivo Y28 8GB / 128GB · Green', 1, 58000, 52000, 0, 58000, 6000)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 15. SALE RETURN (1) — the tempered glass from INV-000001, returned today
--     (16 Nov 2026), refunded Rs 400 in cash. The glass goes back to stock
--     (variant quantity already reflects this: 120 on hand). Money is
--     append-only: the original sale is NOT edited; its status is
--     'partially_returned' and this row is the correction.
-- ---------------------------------------------------------------------------
INSERT INTO sale_returns (id, sale_id, sale_item_id, imei_item_id, quantity, reason, refund_amount, is_exchange, user_id, created_at) VALUES
  ('22000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001',
   '21000000-0000-4000-8000-000000000002', NULL, 1,
   'Tempered glass cracked while fitting; refunded in full', 400, FALSE,
   '10000000-0000-4000-8000-000000000003', '2026-11-16 11:00:00+05')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------------
-- 17. LEDGER ENTRIES (12) — running balances, one row per money event.
--     CUSTOMER side: debit = udhaar added (sale balance / opening),
--       credit = payment received. balance_after = what the customer owes.
--       Bilal 14000, Usman 24000, Asif 38000, Hassan Ali 5000, Ali Hamza 15000.
--     SUPPLIER side: credit = payable added (purchase total),
--       debit = payment made. balance_after = what the shop owes.
--       Hassan Mobile Traders 244500, Bilal Electronics 157500.
-- ---------------------------------------------------------------------------
INSERT INTO ledger_entries (id, side, customer_id, supplier_id, reference_type, reference_id, debit, credit, balance_after, entry_date, user_id, notes) VALUES
  ('24000000-0000-4000-8000-000000000001', 'customer', '16000000-0000-4000-8000-000000000002', NULL, 'sale', '20000000-0000-4000-8000-000000000002', 24000, 0, 24000, '2026-11-11 13:05:00+05', '10000000-0000-4000-8000-000000000003', 'Udhaar on INV-000002 (44000 - 20000 paid)'),
  ('24000000-0000-4000-8000-000000000002', 'customer', '16000000-0000-4000-8000-000000000002', NULL, 'payment', '23000000-0000-4000-8000-000000000003', 0, 10000, 14000, '2026-11-14 10:00:00+05', '10000000-0000-4000-8000-000000000003', 'JazzCash recovery JC-88421057'),
  ('24000000-0000-4000-8000-000000000003', 'customer', '16000000-0000-4000-8000-000000000003', NULL, 'sale', '20000000-0000-4000-8000-000000000003', 24000, 0, 24000, '2026-10-15 17:40:00+05', '10000000-0000-4000-8000-000000000003', 'Installment balance on INV-000003 (39000 - 15000 down)'),
  ('24000000-0000-4000-8000-000000000004', 'customer', '16000000-0000-4000-8000-000000000004', NULL, 'sale', '20000000-0000-4000-8000-000000000005', 38000, 0, 38000, '2026-11-14 12:30:00+05', '10000000-0000-4000-8000-000000000003', 'Installment balance on INV-000005 (58000 - 20000 down)'),
  ('24000000-0000-4000-8000-000000000005', 'customer', '16000000-0000-4000-8000-000000000005', NULL, 'opening', '16000000-0000-4000-8000-000000000005', 5000, 0, 5000, '2026-11-01 09:00:00+05', '10000000-0000-4000-8000-000000000001', 'Opening udhaar balance'),
  ('24000000-0000-4000-8000-000000000006', 'customer', '16000000-0000-4000-8000-000000000007', NULL, 'opening', '16000000-0000-4000-8000-000000000007', 15000, 0, 15000, '2026-11-01 09:00:00+05', '10000000-0000-4000-8000-000000000001', 'Opening udhaar balance'),
  ('24000000-0000-4000-8000-000000000007', 'supplier', NULL, '17000000-0000-4000-8000-000000000001', 'purchase', '18000000-0000-4000-8000-000000000001', 0, 451000, 451000, '2026-11-02 10:30:00+05', '10000000-0000-4000-8000-000000000002', 'Payable on PUR-001'),
  ('24000000-0000-4000-8000-000000000008', 'supplier', NULL, '17000000-0000-4000-8000-000000000001', 'payment', '23000000-0000-4000-8000-000000000007', 451000, 0, 0, '2026-11-02 10:30:00+05', '10000000-0000-4000-8000-000000000002', 'PUR-001 paid in full'),
  ('24000000-0000-4000-8000-000000000009', 'supplier', NULL, '17000000-0000-4000-8000-000000000001', 'purchase', '18000000-0000-4000-8000-000000000003', 0, 944500, 944500, '2026-11-09 11:15:00+05', '10000000-0000-4000-8000-000000000002', 'Payable on PUR-003'),
  ('24000000-0000-4000-8000-000000000010', 'supplier', NULL, '17000000-0000-4000-8000-000000000001', 'payment', '23000000-0000-4000-8000-000000000009', 700000, 0, 244500, '2026-11-09 11:15:00+05', '10000000-0000-4000-8000-000000000002', 'Part payment PUR-003'),
  ('24000000-0000-4000-8000-000000000011', 'supplier', NULL, '17000000-0000-4000-8000-000000000002', 'purchase', '18000000-0000-4000-8000-000000000002', 0, 457500, 457500, '2026-11-05 12:00:00+05', '10000000-0000-4000-8000-000000000002', 'Payable on PUR-002'),
  ('24000000-0000-4000-8000-000000000012', 'supplier', NULL, '17000000-0000-4000-8000-000000000002', 'payment', '23000000-0000-4000-8000-000000000008', 300000, 0, 157500, '2026-11-05 12:00:00+05', '10000000-0000-4000-8000-000000000002', 'Part payment PUR-002')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 18. INSTALLMENTS (2 plans)
--     Plan 1 (Usman Ghani, INV-000003): total 39000, down 15000,
--       3 x 8000. First installment due 15 Nov 2026 is OVERDUE (unpaid).
--     Plan 2 (Muhammad Asif, INV-000005): total 58000, down 20000,
--       4 x 9500, all pending, first due 14 Dec 2026.
-- ---------------------------------------------------------------------------
INSERT INTO installments (id, sale_id, customer_id, total_amount, down_payment, installment_count, installment_amount, start_date, status) VALUES
  ('25000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000003', '16000000-0000-4000-8000-000000000003', 39000, 15000, 3, 8000, '2026-10-15', 'active'),
  ('25000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000005', '16000000-0000-4000-8000-000000000004', 58000, 20000, 4, 9500, '2026-11-14', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO installment_payments (id, installment_id, due_date, amount, paid_amount, paid_date, status, reminder_sent) VALUES
  ('26000000-0000-4000-8000-000000000001', '25000000-0000-4000-8000-000000000001', '2026-11-15', 8000, 0, NULL, 'overdue', TRUE),
  ('26000000-0000-4000-8000-000000000002', '25000000-0000-4000-8000-000000000001', '2026-12-15', 8000, 0, NULL, 'pending', FALSE),
  ('26000000-0000-4000-8000-000000000003', '25000000-0000-4000-8000-000000000001', '2027-01-15', 8000, 0, NULL, 'pending', FALSE),
  ('26000000-0000-4000-8000-000000000004', '25000000-0000-4000-8000-000000000002', '2026-12-14', 9500, 0, NULL, 'pending', FALSE),
  ('26000000-0000-4000-8000-000000000005', '25000000-0000-4000-8000-000000000002', '2027-01-14', 9500, 0, NULL, 'pending', FALSE),
  ('26000000-0000-4000-8000-000000000006', '25000000-0000-4000-8000-000000000002', '2027-02-14', 9500, 0, NULL, 'pending', FALSE),
  ('26000000-0000-4000-8000-000000000007', '25000000-0000-4000-8000-000000000002', '2027-03-14', 9500, 0, NULL, 'pending', FALSE)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 19. REPAIRS (2) + REPAIR PART (1)
--     REP-000001: Infinix Hot 50 screen, READY for pickup, Rs 2000 advance.
--     REP-000002: Samsung Galaxy A15 battery, IN PROGRESS.
-- ---------------------------------------------------------------------------
INSERT INTO repairs (id, job_no, customer_id, customer_name, customer_phone, device_brand, device_model, imei, fault_description, estimated_cost, final_cost, advance_paid, status, received_date, ready_date, delivered_date, user_id, notes) VALUES
  ('27000000-0000-4000-8000-000000000001', 'REP-000001', '16000000-0000-4000-8000-000000000006', 'Fatima Zahra', '03067890123', 'Infinix', 'Hot 50', '860234567890199', 'Screen cracked, touch not working', 6500, 6000, 2000, 'ready', '2026-11-13 14:00:00+05', '2026-11-15 16:30:00+05', NULL, '10000000-0000-4000-8000-000000000002', 'Customer informed by phone; balance Rs 4000 on delivery.'),
  ('27000000-0000-4000-8000-000000000002', 'REP-000002', '16000000-0000-4000-8000-000000000007', 'Ali Hamza', '03078901234', 'Samsung', 'Galaxy A15', '860123456789099', 'Battery drains fast, phone switches off at 30%', 2500, 0, 0, 'in_progress', '2026-11-15 10:15:00+05', NULL, NULL, '10000000-0000-4000-8000-000000000003', 'Battery ordered from Lahore; expected 17 Nov.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO repair_parts (id, repair_id, product_id, variant_id, name, quantity, unit_price, total) VALUES
  ('28000000-0000-4000-8000-000000000001', '27000000-0000-4000-8000-000000000001', NULL, NULL, 'Infinix Hot 50 Display Panel (Original)', 1, 4500, 4500)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------------
-- PAYMENTS (10) -- placed AFTER repairs/installments: payments
--     Sale payments add up to each sale's paid_amount:
--       INV-000001 54000, INV-000002 20000 + 10000 = 30000,
--       INV-000003 15000, INV-000004 75000, INV-000005 20000.
--     Purchase payments add up to each purchase's paid_amount:
--       PUR-001 451000, PUR-002 300000, PUR-003 700000.
-- ---------------------------------------------------------------------------
INSERT INTO payments (id, payment_type, sale_id, purchase_id, installment_id, repair_id, customer_id, supplier_id, method, amount, reference, payment_date, user_id, notes, client_uuid) VALUES
  ('23000000-0000-4000-8000-000000000001', 'sale', '20000000-0000-4000-8000-000000000001', NULL, NULL, NULL, '16000000-0000-4000-8000-000000000001', NULL, 'cash', 54000, NULL, '2026-11-10 18:20:00+05', '10000000-0000-4000-8000-000000000003', 'Full payment INV-000001', '42000000-0000-4000-8000-000000000001'),
  ('23000000-0000-4000-8000-000000000002', 'sale', '20000000-0000-4000-8000-000000000002', NULL, NULL, NULL, '16000000-0000-4000-8000-000000000002', NULL, 'cash', 20000, NULL, '2026-11-11 13:05:00+05', '10000000-0000-4000-8000-000000000003', 'Part payment at sale INV-000002', '42000000-0000-4000-8000-000000000002'),
  ('23000000-0000-4000-8000-000000000003', 'sale', '20000000-0000-4000-8000-000000000002', NULL, NULL, NULL, '16000000-0000-4000-8000-000000000002', NULL, 'jazzcash', 10000, 'JC-88421057', '2026-11-14 10:00:00+05', '10000000-0000-4000-8000-000000000003', 'Udhaar recovery against INV-000002', '42000000-0000-4000-8000-000000000003'),
  ('23000000-0000-4000-8000-000000000004', 'sale', '20000000-0000-4000-8000-000000000003', NULL, NULL, NULL, '16000000-0000-4000-8000-000000000003', NULL, 'cash', 15000, NULL, '2026-10-15 17:40:00+05', '10000000-0000-4000-8000-000000000003', 'Down payment INV-000003', '42000000-0000-4000-8000-000000000004'),
  ('23000000-0000-4000-8000-000000000005', 'sale', '20000000-0000-4000-8000-000000000004', NULL, NULL, NULL, NULL, NULL, 'cash', 75000, NULL, '2026-11-13 19:10:00+05', '10000000-0000-4000-8000-000000000003', 'Full payment INV-000004 (walk-in)', '42000000-0000-4000-8000-000000000005'),
  ('23000000-0000-4000-8000-000000000006', 'sale', '20000000-0000-4000-8000-000000000005', NULL, NULL, NULL, '16000000-0000-4000-8000-000000000004', NULL, 'cash', 20000, NULL, '2026-11-14 12:30:00+05', '10000000-0000-4000-8000-000000000003', 'Down payment INV-000005', '42000000-0000-4000-8000-000000000006'),
  ('23000000-0000-4000-8000-000000000007', 'purchase', NULL, '18000000-0000-4000-8000-000000000001', NULL, NULL, NULL, '17000000-0000-4000-8000-000000000001', 'cash', 451000, NULL, '2026-11-02 10:30:00+05', '10000000-0000-4000-8000-000000000002', 'Paid in full PUR-001', '42000000-0000-4000-8000-000000000007'),
  ('23000000-0000-4000-8000-000000000008', 'purchase', NULL, '18000000-0000-4000-8000-000000000002', NULL, NULL, NULL, '17000000-0000-4000-8000-000000000002', 'bank_transfer', 300000, 'IBFT-HBL-55231', '2026-11-05 12:00:00+05', '10000000-0000-4000-8000-000000000002', 'Part payment PUR-002', '42000000-0000-4000-8000-000000000008'),
  ('23000000-0000-4000-8000-000000000009', 'purchase', NULL, '18000000-0000-4000-8000-000000000003', NULL, NULL, NULL, '17000000-0000-4000-8000-000000000001', 'cash', 700000, NULL, '2026-11-09 11:15:00+05', '10000000-0000-4000-8000-000000000002', 'Part payment PUR-003', '42000000-0000-4000-8000-000000000009'),
  ('23000000-0000-4000-8000-000000000010', 'repair', NULL, NULL, NULL, '27000000-0000-4000-8000-000000000001', '16000000-0000-4000-8000-000000000006', NULL, 'cash', 2000, NULL, '2026-11-15 15:00:00+05', '10000000-0000-4000-8000-000000000002', 'Advance for repair REP-000001', '42000000-0000-4000-8000-000000000010')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 20. SERVICE SALES (2) — EasyLoad / bill payment with commission.
-- ---------------------------------------------------------------------------
INSERT INTO service_sales (id, service_type, customer_phone, provider, amount, commission, user_id, sale_date) VALUES
  ('29000000-0000-4000-8000-000000000001', 'easyload', '03012345678', 'Jazz', 1000, 30, '10000000-0000-4000-8000-000000000003', '2026-11-15 18:00:00+05'),
  ('29000000-0000-4000-8000-000000000002', 'bill_payment', '03023456789', 'MEPCO', 5000, 50, '10000000-0000-4000-8000-000000000003', '2026-11-16 09:30:00+05')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 21. EXPENSES (4) — November 2026.
-- ---------------------------------------------------------------------------
INSERT INTO expenses (id, branch_id, category, amount, expense_date, description, user_id) VALUES
  ('30000000-0000-4000-8000-000000000001', (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1), 'rent', 35000, '2026-11-01 09:00:00+05', 'November shop rent — Jamal Chowk', '10000000-0000-4000-8000-000000000001'),
  ('30000000-0000-4000-8000-000000000002', (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1), 'electricity', 8200, '2026-11-10 10:00:00+05', 'MEPCO bill October 2026', '10000000-0000-4000-8000-000000000001'),
  ('30000000-0000-4000-8000-000000000003', (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1), 'transport', 3500, '2026-11-05 13:00:00+05', 'Lahore stock pickup — Hall Road', '10000000-0000-4000-8000-000000000002'),
  ('30000000-0000-4000-8000-000000000004', (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1), 'other', 1200, '2026-11-14 11:00:00+05', 'Tea, cleaning and misc shop items', '10000000-0000-4000-8000-000000000003')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 22. STAFF (2) + SALARY PAYMENT (1)
-- ---------------------------------------------------------------------------
INSERT INTO staff (id, name, phone, role, salary) VALUES
  ('31000000-0000-4000-8000-000000000001', 'Muhammad Bilal', '03011112222', 'Salesman', 35000),
  ('31000000-0000-4000-8000-000000000002', 'Ayesha Siddique', '03033334444', 'Cashier Assistant', 30000)
ON CONFLICT (id) DO NOTHING;

INSERT INTO salary_payments (id, staff_id, month, amount, advance, paid_date, user_id, notes) VALUES
  ('32000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', '2026-10', 35000, 0, '2026-11-05 18:00:00+05', '10000000-0000-4000-8000-000000000001', 'October 2026 salary — Muhammad Bilal')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 23. CASH REGISTER — today (16 Nov 2026), still OPEN.
--     Opening cash 50000; owner added 20000 float; Rs 400 paid out for the
--     glass refund (INV-000001). Expected cash at close =
--     50000 + 20000 - 400 = 69600 (before any further cash sales today).
-- ---------------------------------------------------------------------------
INSERT INTO cash_register (id, branch_id, register_date, opening_cash, closing_cash, expected_cash, difference, status, opened_by, closed_by, notes) VALUES
  ('33000000-0000-4000-8000-000000000001',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '2026-11-16', 50000, NULL, NULL, NULL, 'open',
   '10000000-0000-4000-8000-000000000001', NULL, 'Opening cash counted by Anas Zaheer')
ON CONFLICT (id) DO NOTHING;

INSERT INTO cash_movements (id, register_id, type, amount, reason, user_id) VALUES
  ('34000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'in', 20000, 'Owner added float cash', '10000000-0000-4000-8000-000000000001'),
  ('34000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', 'out', 400, 'Refund — tempered glass return INV-000001', '10000000-0000-4000-8000-000000000003')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 24. HELD BILL (1) — a parked bill the cashier can resume.
-- ---------------------------------------------------------------------------
INSERT INTO held_bills (id, branch_id, user_id, customer_name, cart) VALUES
  ('35000000-0000-4000-8000-000000000001',
   (SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1),
   '10000000-0000-4000-8000-000000000003', 'Walk-in Customer',
   '[{"variant_id": "14000000-0000-4000-8000-000000000018", "name": "Oraimo Fast Charger 25W", "quantity": 1, "unit_price": 2000}]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 25. COUNTERS — invoice numbers continue from the seed data:
--     next sale invoice is INV-000006, next repair job REP-000003,
--     next purchase PUR-004.
-- ---------------------------------------------------------------------------
INSERT INTO counters (branch_id, name, prefix, last_value) VALUES
  ((SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1), 'sale_invoice', 'INV', 5),
  ((SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1), 'repair_job', 'REP', 2),
  ((SELECT id FROM branches WHERE name = 'Baba Farid Mobiles' ORDER BY created_at ASC LIMIT 1), 'purchase', 'PUR', 3)
ON CONFLICT (branch_id, name) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 26. AUDIT LOGS (3) + SYNC LOGS (2) — sample trail rows.
-- ---------------------------------------------------------------------------
INSERT INTO audit_logs (id, user_id, action, entity_type, entity_id, old_values, new_values, ip_address, device_info) VALUES
  ('36000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'login', 'user', '10000000-0000-4000-8000-000000000001', NULL, '{"username": "admin"}'::jsonb, '192.168.1.10', 'POS-01 Android'),
  ('36000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000003', 'sale', 'sale', '20000000-0000-4000-8000-000000000001', NULL, '{"invoice_no": "INV-000001", "grand_total": 54000}'::jsonb, '192.168.1.10', 'POS-01 Android'),
  ('36000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', 'create', 'purchase', '18000000-0000-4000-8000-000000000003', NULL, '{"supplier_invoice_no": "HMT-2026-1109", "grand_total": 944500}'::jsonb, '192.168.1.11', 'Manager laptop')
ON CONFLICT (id) DO NOTHING;

INSERT INTO sync_logs (id, device_id, user_id, entity_type, entity_id, action, detail) VALUES
  ('37000000-0000-4000-8000-000000000001', 'POS-01', '10000000-0000-4000-8000-000000000003', 'sale', '20000000-0000-4000-8000-000000000001', 'push', '{"client_uuid": "40000000-0000-4000-8000-000000000001", "result": "applied"}'::jsonb),
  ('37000000-0000-4000-8000-000000000002', 'POS-01', '10000000-0000-4000-8000-000000000003', 'product', NULL, 'pull', '{"since": "2026-11-15T00:00:00Z", "rows": 21}'::jsonb)
ON CONFLICT (id) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES — run these after the seed to confirm consistency.
-- Expected values are in the comments. All money is whole PKR.
-- ============================================================================
-- Row counts:
--   SELECT 'roles', count(*) FROM roles
--   UNION ALL SELECT 'users', count(*) FROM users
--   UNION ALL SELECT 'categories', count(*) FROM categories
--   UNION ALL SELECT 'brands', count(*) FROM brands
--   UNION ALL SELECT 'products', count(*) FROM products
--   UNION ALL SELECT 'product_variants', count(*) FROM product_variants
--   UNION ALL SELECT 'imei_items', count(*) FROM imei_items
--   UNION ALL SELECT 'customers', count(*) FROM customers
--   UNION ALL SELECT 'suppliers', count(*) FROM suppliers
--   UNION ALL SELECT 'purchases', count(*) FROM purchases
--   UNION ALL SELECT 'purchase_items', count(*) FROM purchase_items
--   UNION ALL SELECT 'sales', count(*) FROM sales
--   UNION ALL SELECT 'sale_items', count(*) FROM sale_items
--   UNION ALL SELECT 'sale_returns', count(*) FROM sale_returns
--   UNION ALL SELECT 'payments', count(*) FROM payments
--   UNION ALL SELECT 'ledger_entries', count(*) FROM ledger_entries
--   UNION ALL SELECT 'installments', count(*) FROM installments
--   UNION ALL SELECT 'installment_payments', count(*) FROM installment_payments
--   UNION ALL SELECT 'repairs', count(*) FROM repairs
--   UNION ALL SELECT 'expenses', count(*) FROM expenses
--   UNION ALL SELECT 'cash_register', count(*) FROM cash_register;
-- Expected: roles 3, users 3, categories 7, brands 15, products 21,
--   variants 26, imei_items 30, customers 10, suppliers 2, purchases 3,
--   purchase_items 39, sales 5, sale_items 10, sale_returns 1, payments 10,
--   ledger_entries 12, installments 2, installment_payments 7, repairs 2,
--   expenses 4, cash_register 1.
--
-- IMEI sold check (expect 5 rows, all with a matching sale):
--   SELECT i.imei1, i.status, s.invoice_no FROM imei_items i
--   JOIN sales s ON s.id = i.sold_sale_id WHERE i.status = 'sold';
-- IMEI available check (expect 25):
--   SELECT count(*) FROM imei_items WHERE status = 'available';
-- Sale totals check (expect 0 rows — every sale's items sum to its totals):
--   SELECT s.invoice_no FROM sales s
--   WHERE s.grand_total <> (SELECT COALESCE(sum(total),0) FROM sale_items WHERE sale_id = s.id)
--      OR s.paid_amount + s.balance_due <> s.grand_total;
-- Purchase totals check (expect 0 rows):
--   SELECT p.id FROM purchases p
--   WHERE p.grand_total <> (SELECT COALESCE(sum(total),0) FROM purchase_items WHERE purchase_id = p.id)
--      OR p.paid_amount + p.balance_due <> p.grand_total;
-- Customer balances (expect Bilal 14000, Usman 24000, Asif 38000,
--   Hassan Ali 5000, Ali Hamza 15000 — latest balance_after per customer):
--   SELECT DISTINCT ON (customer_id) customer_id, balance_after
--   FROM ledger_entries WHERE side = 'customer' ORDER BY customer_id, entry_date DESC;
-- Supplier balances (expect Hassan Mobile Traders 244500, Bilal Electronics 157500):
--   SELECT DISTINCT ON (supplier_id) supplier_id, balance_after
--   FROM ledger_entries WHERE side = 'supplier' ORDER BY supplier_id, entry_date DESC;
-- Total seed profit (expect 28770):
--   SELECT sum(profit) FROM sale_items;
-- Overdue installments (expect 1 — Usman Ghani, Rs 8000, due 2026-11-15):
--   SELECT * FROM installment_payments WHERE status = 'overdue';
-- ============================================================================
-- END OF SEED — Baba Farid Mobiles
-- ============================================================================
