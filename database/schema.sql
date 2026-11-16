-- ============================================================================
-- Baba Farid Mobiles — Billing & Inventory Management System
-- Module 3: Database Schema (PostgreSQL 16)
-- Currency: PKR (whole rupees — all money is NUMERIC(12,0), no paisa)
-- IDs: UUID (gen_random_uuid) so devices can create records OFFLINE and
-- sync later without ID collisions. Money records carry a client_uuid for
-- idempotent sync (same client_uuid = never applied twice).
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------------
-- Helper: auto-update updated_at on every row change
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- ENUM types (statuses used across the system)
-- ---------------------------------------------------------------------------
CREATE TYPE user_role AS ENUM ('owner', 'manager', 'cashier');
CREATE TYPE item_condition AS ENUM ('new', 'used', 'open_box');
CREATE TYPE pta_status AS ENUM ('approved', 'non_pta', 'not_applicable');
CREATE TYPE imei_status AS ENUM ('available', 'sold', 'reserved', 'returned', 'defective');
CREATE TYPE payment_method AS ENUM ('cash', 'jazzcash', 'easypaisa', 'bank_transfer', 'card', 'partial', 'udhaar');
CREATE TYPE payment_status AS ENUM ('paid', 'partial', 'unpaid');
CREATE TYPE sale_status AS ENUM ('completed', 'returned', 'partially_returned', 'cancelled', 'held');
CREATE TYPE purchase_status AS ENUM ('received', 'partially_returned', 'returned', 'cancelled');
CREATE TYPE installment_status AS ENUM ('active', 'completed', 'defaulted');
CREATE TYPE installment_pay_status AS ENUM ('pending', 'partial', 'paid', 'overdue');
CREATE TYPE repair_status AS ENUM ('received', 'in_progress', 'ready', 'delivered', 'cancelled');
CREATE TYPE register_status AS ENUM ('open', 'closed');
CREATE TYPE ledger_side AS ENUM ('customer', 'supplier');
CREATE TYPE cash_move_type AS ENUM ('in', 'out');

-- ============================================================================
-- 1. ORGANISATION, USERS & ROLES
-- ============================================================================

CREATE TABLE branches (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  address     TEXT,
  phone       TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE roles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        user_role NOT NULL UNIQUE,
  description TEXT,
  -- permissions: JSON object, e.g. {"sales.create": true, "reports.profit": false}
  permissions JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id     UUID REFERENCES branches(id),
  role_id       UUID NOT NULL REFERENCES roles(id),
  name          TEXT NOT NULL,
  phone         TEXT NOT NULL UNIQUE,
  email         TEXT UNIQUE,
  password_hash TEXT NOT NULL,              -- bcrypt, cost 12. Never plain text.
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_branch ON users(branch_id);

-- ============================================================================
-- 2. CATALOG: categories, brands, products, variants
-- ============================================================================

CREATE TABLE categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,                -- e.g. "Mobile Phones", "Chargers"
  type        TEXT NOT NULL CHECK (type IN ('phone', 'accessory', 'service')),
  parent_id   UUID REFERENCES categories(id),
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE brands (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL UNIQUE,         -- Samsung, Infinix, Tecno, Apple ...
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE products (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id    UUID REFERENCES brands(id),
  category_id UUID REFERENCES categories(id),
  type        TEXT NOT NULL CHECK (type IN ('phone', 'accessory')),
  name        TEXT NOT NULL,                -- e.g. "Galaxy A15", "Fast Charger 25W"
  description TEXT,
  barcode     TEXT UNIQUE,                  -- product-level barcode (accessories)
  image_url   TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_products_brand ON products(brand_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_name ON products USING gin (to_tsvector('english', name));

CREATE TABLE product_variants (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id          UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,        -- e.g. "8GB / 128GB · Black"
  color               TEXT,
  storage_gb          INT,
  ram_gb              INT,
  condition           item_condition NOT NULL DEFAULT 'new',
  pta_status          pta_status NOT NULL DEFAULT 'not_applicable',
  barcode             TEXT UNIQUE,          -- variant-level barcode
  purchase_price      NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (purchase_price >= 0),
  sale_price          NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (sale_price >= 0),
  min_price           NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (min_price >= 0),
  warranty_months     INT NOT NULL DEFAULT 0 CHECK (warranty_months >= 0),
  -- quantity is used for ACCESSORIES (quantity-based stock).
  -- For PHONES, stock = count of imei_items with status='available'.
  quantity            INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  low_stock_threshold INT NOT NULL DEFAULT 3 CHECK (low_stock_threshold >= 0),
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_variants_product ON product_variants(product_id);

-- ============================================================================
-- 3. IMEI-LEVEL STOCK (every phone is a unique item)
-- ============================================================================

CREATE TABLE imei_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id      UUID NOT NULL REFERENCES products(id),
  variant_id      UUID REFERENCES product_variants(id),
  imei1           TEXT NOT NULL UNIQUE,     -- UNIQUE: duplicate IMEI can never be entered
  imei2           TEXT UNIQUE,              -- nullable; unique where present
  status          imei_status NOT NULL DEFAULT 'available',
  purchase_id     UUID,                     -- set by purchase (FK added after purchases table)
  purchase_price  NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (purchase_price >= 0),
  sale_price      NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (sale_price >= 0),
  sold_sale_id    UUID,                     -- set when sold (FK added after sales table)
  warranty_start  DATE,
  warranty_end    DATE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_imei_status ON imei_items(status);
CREATE INDEX idx_imei_product ON imei_items(product_id);
-- A sold IMEI must never be sold again: the app only sells status='available',
-- and this partial index lets us find every sold unit instantly.
CREATE INDEX idx_imei_sold ON imei_items(imei1) WHERE status = 'sold';

-- ============================================================================
-- 4. CUSTOMERS & SUPPLIERS
-- ============================================================================

CREATE TABLE customers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  phone           TEXT NOT NULL,
  cnic            TEXT,                     -- optional
  address         TEXT,
  opening_balance NUMERIC(12,0) NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_name ON customers USING gin (to_tsvector('english', name));

CREATE TABLE suppliers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  phone           TEXT,
  address         TEXT,
  opening_payable NUMERIC(12,0) NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_suppliers_phone ON suppliers(phone);

-- ============================================================================
-- 5. SALES (bills) & SALE ITEMS
-- ============================================================================

CREATE TABLE sales (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_no       TEXT NOT NULL UNIQUE,    -- e.g. INV-000123 (per branch sequence)
  branch_id        UUID REFERENCES branches(id),
  customer_id      UUID REFERENCES customers(id),  -- NULL = walk-in customer
  customer_name    TEXT,                    -- snapshot (walk-in or at time of sale)
  customer_phone   TEXT,
  user_id          UUID NOT NULL REFERENCES users(id),  -- cashier who made the bill
  sale_date        TIMESTAMPTZ NOT NULL DEFAULT now(),
  subtotal         NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
  discount_amount  NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
  discount_percent NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
  tax_amount       NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
  grand_total      NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (grand_total >= 0),
  paid_amount      NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
  balance_due      NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (balance_due >= 0),
  payment_method   payment_method NOT NULL DEFAULT 'cash',
  payment_status   payment_status NOT NULL DEFAULT 'paid',
  status           sale_status NOT NULL DEFAULT 'completed',
  notes            TEXT,
  client_uuid      UUID UNIQUE,             -- idempotency key for offline sync
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (discount_amount <= subtotal),
  CHECK (paid_amount <= grand_total)
);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_sales_user ON sales(user_id);
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_branch_date ON sales(branch_id, sale_date);
CREATE INDEX idx_sales_status ON sales(status);

CREATE TABLE sale_items (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id        UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  product_id     UUID REFERENCES products(id),
  variant_id     UUID REFERENCES product_variants(id),
  imei_item_id   UUID REFERENCES imei_items(id),
  name_snapshot  TEXT NOT NULL,             -- product name at time of sale
  quantity       INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price     NUMERIC(12,0) NOT NULL CHECK (unit_price >= 0),
  purchase_cost  NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (purchase_cost >= 0),
  discount       NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (discount >= 0),
  total          NUMERIC(12,0) NOT NULL CHECK (total >= 0),
  -- profit is derived: total - (purchase_cost * quantity). Stored for fast reports.
  profit         NUMERIC(12,0) NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX idx_sale_items_imei ON sale_items(imei_item_id);
CREATE INDEX idx_sale_items_product ON sale_items(product_id);

-- Sale returns / exchanges (money is append-only: a return is a new record,
-- never an edit of the original sale).
CREATE TABLE sale_returns (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id       UUID NOT NULL REFERENCES sales(id),
  sale_item_id  UUID REFERENCES sale_items(id),
  imei_item_id  UUID REFERENCES imei_items(id),
  quantity      INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  reason        TEXT,
  refund_amount NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (refund_amount >= 0),
  is_exchange   BOOLEAN NOT NULL DEFAULT FALSE,
  -- for an exchange, the replacement item is a new sale_item on a new sale
  exchange_sale_id UUID REFERENCES sales(id),
  user_id       UUID NOT NULL REFERENCES users(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_returns_sale ON sale_returns(sale_id);

-- Held bills (bill is parked, can be resumed later).
CREATE TABLE held_bills (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id   UUID REFERENCES branches(id),
  user_id     UUID NOT NULL REFERENCES users(id),
  customer_name TEXT,
  cart        JSONB NOT NULL DEFAULT '[]'::jsonb,  -- items, quantities, discounts
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 6. PURCHASES & SUPPLIER PAYABLES
-- ============================================================================

CREATE TABLE purchases (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id     UUID NOT NULL REFERENCES suppliers(id),
  branch_id       UUID REFERENCES branches(id),
  user_id         UUID NOT NULL REFERENCES users(id),
  supplier_invoice_no TEXT,                 -- supplier's own invoice number
  purchase_date   TIMESTAMPTZ NOT NULL DEFAULT now(),
  subtotal        NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
  discount        NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (discount >= 0),
  grand_total     NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (grand_total >= 0),
  paid_amount     NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
  balance_due     NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (balance_due >= 0),
  status          purchase_status NOT NULL DEFAULT 'received',
  notes           TEXT,
  client_uuid     UUID UNIQUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (paid_amount <= grand_total)
);
CREATE INDEX idx_purchases_supplier ON purchases(supplier_id);
CREATE INDEX idx_purchases_date ON purchases(purchase_date);

CREATE TABLE purchase_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id  UUID NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
  product_id   UUID REFERENCES products(id),
  variant_id   UUID REFERENCES product_variants(id),
  imei1        TEXT,                        -- one row per phone IMEI
  imei2        TEXT,
  catalog_sku  TEXT,                        -- catalog accessory SKU (no product/variant row in the main DB)
  quantity     INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_cost    NUMERIC(12,0) NOT NULL CHECK (unit_cost >= 0),
  total        NUMERIC(12,0) NOT NULL CHECK (total >= 0),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_purchase_items_purchase ON purchase_items(purchase_id);

-- Purchase returns (goods sent back to supplier).
CREATE TABLE purchase_returns (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id  UUID NOT NULL REFERENCES purchases(id),
  imei_item_id UUID REFERENCES imei_items(id),
  product_id   UUID REFERENCES products(id),
  variant_id   UUID REFERENCES product_variants(id),
  catalog_sku  TEXT,                        -- catalog accessory SKU returned (mirrors purchase_items.catalog_sku)
  quantity     INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  reason       TEXT,
  refund_amount NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (refund_amount >= 0),
  user_id      UUID NOT NULL REFERENCES users(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Now that sales & purchases exist, wire up the IMEI foreign keys.
ALTER TABLE imei_items
  ADD CONSTRAINT fk_imei_purchase FOREIGN KEY (purchase_id) REFERENCES purchases(id),
  ADD CONSTRAINT fk_imei_sale FOREIGN KEY (sold_sale_id) REFERENCES sales(id);

-- ============================================================================
-- 7. PAYMENTS, LEDGER & INSTALLMENTS
-- ============================================================================

-- Every money movement (sale payment, purchase payment, installment, udhaar
-- recovery) is a row here. Never edited — corrections are new rows.
CREATE TABLE payments (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_type   TEXT NOT NULL CHECK (payment_type IN
                   ('sale', 'purchase', 'installment', 'udhaar_recovery', 'repair', 'other')),
  sale_id        UUID REFERENCES sales(id),
  purchase_id    UUID REFERENCES purchases(id),
  installment_id UUID,                      -- FK added after installments table
  repair_id      UUID,                      -- FK added after repairs table
  customer_id    UUID REFERENCES customers(id),
  supplier_id    UUID REFERENCES suppliers(id),
  method         payment_method NOT NULL DEFAULT 'cash',
  amount         NUMERIC(12,0) NOT NULL CHECK (amount > 0),
  reference      TEXT,                      -- JazzCash/Easypaisa TID, bank ref, cheque no.
  payment_date   TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id        UUID NOT NULL REFERENCES users(id),
  notes          TEXT,
  client_uuid    UUID UNIQUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_payments_sale ON payments(sale_id);
CREATE INDEX idx_payments_customer ON payments(customer_id);
CREATE INDEX idx_payments_supplier ON payments(supplier_id);
CREATE INDEX idx_payments_date ON payments(payment_date);

-- Running-balance ledger (one row per entry; balance_after is the balance
-- immediately after this entry — makes statements fast and auditable).
CREATE TABLE ledger_entries (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  side           ledger_side NOT NULL,      -- 'customer' (udhaar) or 'supplier' (payable)
  customer_id    UUID REFERENCES customers(id),
  supplier_id    UUID REFERENCES suppliers(id),
  reference_type TEXT NOT NULL,             -- sale, purchase, payment, return, installment, opening
  reference_id   UUID,
  debit          NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (debit >= 0),
  credit         NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (credit >= 0),
  balance_after  NUMERIC(12,0) NOT NULL DEFAULT 0,
  entry_date     TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id        UUID REFERENCES users(id),
  notes          TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK ((side = 'customer' AND customer_id IS NOT NULL AND supplier_id IS NULL)
      OR (side = 'supplier' AND supplier_id IS NOT NULL AND customer_id IS NULL))
);
CREATE INDEX idx_ledger_customer ON ledger_entries(customer_id, entry_date);
CREATE INDEX idx_ledger_supplier ON ledger_entries(supplier_id, entry_date);

CREATE TABLE installments (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id           UUID NOT NULL REFERENCES sales(id),
  customer_id       UUID NOT NULL REFERENCES customers(id),
  total_amount      NUMERIC(12,0) NOT NULL CHECK (total_amount > 0),
  down_payment      NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (down_payment >= 0),
  installment_count INT NOT NULL CHECK (installment_count > 0),
  installment_amount NUMERIC(12,0) NOT NULL CHECK (installment_amount > 0),
  start_date        DATE NOT NULL,
  status            installment_status NOT NULL DEFAULT 'active',
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_installments_customer ON installments(customer_id);
CREATE INDEX idx_installments_sale ON installments(sale_id);

CREATE TABLE installment_payments (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  installment_id UUID NOT NULL REFERENCES installments(id) ON DELETE CASCADE,
  due_date       DATE NOT NULL,
  amount         NUMERIC(12,0) NOT NULL CHECK (amount > 0),
  paid_amount    NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
  paid_date      DATE,
  status         installment_pay_status NOT NULL DEFAULT 'pending',
  reminder_sent  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (paid_amount <= amount)
);
CREATE INDEX idx_instpay_due ON installment_payments(due_date, status);
CREATE INDEX idx_instpay_installment ON installment_payments(installment_id);

ALTER TABLE payments
  ADD CONSTRAINT fk_pay_installment FOREIGN KEY (installment_id) REFERENCES installments(id);

-- ============================================================================
-- 8. REPAIRS & SERVICES
-- ============================================================================

CREATE TABLE repairs (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_no           TEXT NOT NULL UNIQUE,    -- e.g. REP-000123
  customer_id      UUID REFERENCES customers(id),
  customer_name    TEXT NOT NULL,
  customer_phone   TEXT NOT NULL,
  device_brand     TEXT,
  device_model     TEXT,
  imei             TEXT,
  fault_description TEXT NOT NULL,
  estimated_cost   NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (estimated_cost >= 0),
  final_cost       NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (final_cost >= 0),
  advance_paid     NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (advance_paid >= 0),
  status           repair_status NOT NULL DEFAULT 'received',
  received_date    TIMESTAMPTZ NOT NULL DEFAULT now(),
  ready_date       TIMESTAMPTZ,
  delivered_date   TIMESTAMPTZ,
  user_id          UUID NOT NULL REFERENCES users(id),
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_repairs_status ON repairs(status);
CREATE INDEX idx_repairs_phone ON repairs(customer_phone);

-- FK from payments to repairs (placed here because the repairs table is
-- defined above; the original ALTER ran before repairs existed and a fresh
-- psql -f schema.sql failed on it).
ALTER TABLE payments
  ADD CONSTRAINT fk_pay_repair FOREIGN KEY (repair_id) REFERENCES repairs(id);
CREATE INDEX idx_repairs_imei ON repairs(imei);

CREATE TABLE repair_parts (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  repair_id    UUID NOT NULL REFERENCES repairs(id) ON DELETE CASCADE,
  product_id   UUID REFERENCES products(id),
  variant_id   UUID REFERENCES product_variants(id),
  name         TEXT NOT NULL,               -- part name snapshot
  quantity     INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price   NUMERIC(12,0) NOT NULL CHECK (unit_price >= 0),
  total        NUMERIC(12,0) NOT NULL CHECK (total >= 0),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Mobile load / recharge / bill-payment sales (with commission).
CREATE TABLE service_sales (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_type  TEXT NOT NULL CHECK (service_type IN ('easyload', 'recharge', 'bill_payment', 'other')),
  customer_phone TEXT,
  provider      TEXT,                       -- Jazz, Telenor, Zong, Ufone, K-Electric, etc.
  amount        NUMERIC(12,0) NOT NULL CHECK (amount > 0),
  commission    NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (commission >= 0),
  user_id       UUID NOT NULL REFERENCES users(id),
  sale_date     TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_service_sales_date ON service_sales(sale_date);

-- ============================================================================
-- 9. EXPENSES, STAFF & CASH MANAGEMENT
-- ============================================================================

CREATE TABLE expenses (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id   UUID REFERENCES branches(id),
  category    TEXT NOT NULL,                -- rent, electricity, salary, transport, other
  amount      NUMERIC(12,0) NOT NULL CHECK (amount > 0),
  expense_date TIMESTAMPTZ NOT NULL DEFAULT now(),
  description TEXT,
  user_id     UUID NOT NULL REFERENCES users(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_expenses_category ON expenses(category);

CREATE TABLE staff (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  phone       TEXT,
  role        TEXT,
  salary      NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (salary >= 0),
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE salary_payments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id    UUID NOT NULL REFERENCES staff(id),
  month       TEXT NOT NULL,                -- '2026-11'
  amount      NUMERIC(12,0) NOT NULL CHECK (amount >= 0),
  advance     NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (advance >= 0),
  paid_date   TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id     UUID NOT NULL REFERENCES users(id),
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE cash_register (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id     UUID REFERENCES branches(id),
  register_date DATE NOT NULL DEFAULT CURRENT_DATE,
  opening_cash  NUMERIC(12,0) NOT NULL DEFAULT 0 CHECK (opening_cash >= 0),
  closing_cash  NUMERIC(12,0),             -- actual counted cash at close
  expected_cash NUMERIC(12,0),             -- system-computed expected cash
  difference    NUMERIC(12,0),             -- actual - expected (can be negative)
  status        register_status NOT NULL DEFAULT 'open',
  opened_by     UUID REFERENCES users(id),
  closed_by     UUID REFERENCES users(id),
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (branch_id, register_date)
);
CREATE INDEX idx_register_date ON cash_register(register_date);

CREATE TABLE cash_movements (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  register_id UUID NOT NULL REFERENCES cash_register(id) ON DELETE CASCADE,
  type        cash_move_type NOT NULL,      -- 'in' (cash added) or 'out' (cash taken)
  amount      NUMERIC(12,0) NOT NULL CHECK (amount > 0),
  reason      TEXT,
  user_id     UUID NOT NULL REFERENCES users(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 10. AUDIT LOG, SETTINGS, SYNC
-- ============================================================================

-- Append-only audit trail: who did what, when, on which record.
CREATE TABLE audit_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  action      TEXT NOT NULL,                -- create, update, delete, login, sale, payment...
  entity_type TEXT NOT NULL,                -- sale, product, customer, settings...
  entity_id   UUID,
  old_values  JSONB,
  new_values  JSONB,
  ip_address  TEXT,
  device_info TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_user ON audit_logs(user_id, created_at);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);

-- Shop settings as key/value rows (one row per setting).
CREATE TABLE settings (
  key         TEXT PRIMARY KEY,             -- shop.name, shop.address, tax.rate...
  value       JSONB NOT NULL,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Invoice-number counters (one row per branch + document type).
CREATE TABLE counters (
  branch_id   UUID REFERENCES branches(id),
  name        TEXT NOT NULL,                -- 'sale_invoice', 'repair_job', 'purchase'
  prefix      TEXT NOT NULL,                -- 'INV', 'REP', 'PUR'
  last_value  BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (branch_id, name)
);

-- Sync log (server side): which device synced what, when. Helps debugging.
CREATE TABLE sync_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id   TEXT NOT NULL,
  user_id     UUID REFERENCES users(id),
  entity_type TEXT NOT NULL,
  entity_id   UUID,
  action      TEXT NOT NULL,                -- push, pull, conflict
  detail      JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_sync_device ON sync_logs(device_id, created_at);

-- ============================================================================
-- 11. updated_at TRIGGERS (apply to every table that has updated_at)
-- ============================================================================
DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT table_name FROM information_schema.columns
           WHERE column_name = 'updated_at' AND table_schema = 'public'
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated ON %I', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_%I_updated BEFORE UPDATE ON %I
       FOR EACH ROW EXECUTE FUNCTION set_updated_at()', t, t);
  END LOOP;
END $$;

-- ============================================================================
-- 12. SEED: default roles & the shop's first branch (Module 9 adds full seed)
-- ============================================================================
INSERT INTO branches (name, address, phone) VALUES
  ('Baba Farid Mobiles', 'Jamal Chowk, Depalpur Road, Pakpattan', '+92 329 9966771')
ON CONFLICT DO NOTHING;

INSERT INTO roles (name, description, permissions) VALUES
  ('owner', 'Full access: everything including profit and settings',
   '{"sales.create": true, "sales.edit": true, "sales.cancel": true, "cost.view": true, "reports.profit": true, "settings.edit": true, "users.manage": true}'::jsonb),
  ('manager', 'Sales, purchases, stock, reports. No profit editing, no settings.',
   '{"sales.create": true, "sales.edit": true, "sales.cancel": false, "cost.view": true, "reports.profit": true, "settings.edit": false, "users.manage": false}'::jsonb),
  ('cashier', 'Create bills only. No cost price visibility.',
   '{"sales.create": true, "sales.edit": false, "sales.cancel": false, "cost.view": false, "reports.profit": false, "settings.edit": false, "users.manage": false}'::jsonb)
ON CONFLICT (name) DO NOTHING;

-- Shop profile defaults (Module 9 / Settings screen can change these).
INSERT INTO settings (key, value) VALUES
  ('shop.name', '"Baba Farid Mobiles"'::jsonb),
  ('shop.address', '"Jamal Chowk, Depalpur Road, Pakpattan"'::jsonb),
  ('shop.phone', '"+92 329 9966771"'::jsonb),
  ('shop.phone2', '"+92 302 4988560"'::jsonb),
  ('shop.email', '"baba.farid.mobiles.bfw@gmail.com"'::jsonb),
  ('shop.currency', '"PKR"'::jsonb),
  ('tax.enabled', 'false'::jsonb),
  ('tax.rate', '0'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- ============================================================================
-- END OF SCHEMA — verify with: psql -d shopdb -f schema.sql
-- Tables: 33 · Enums: 14 · Indexes: 44 · All money: NUMERIC(12,0) (whole PKR)
-- ============================================================================
