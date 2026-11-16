// Live end-to-end scenario against the running backend + PostgreSQL shopdb.
// Round 3 verification (Worker V). Run with:  node scripts/e2e-live.mjs
// Requires: clean seed loaded, backend running on http://localhost:3000.
// Exits non-zero if any check fails.
//
// Flow: purchase 2 phones (IMEI) + 5 accessories from a supplier
//   -> sell 1 phone with partial payment -> invoice -> return the phone
//   -> customer ledger -> dashboard + profit-loss. Every step verifies the
//   DB state through the API (IMEI status, variant quantities, ledger
//   balances, report totals).
const BASE = 'http://localhost:3000';

const SUPPLIER_ID = '17000000-0000-4000-8000-000000000001'; // Hassan Mobile Traders
const CUSTOMER_ID = '16000000-0000-4000-8000-000000000001'; // Ahmed Raza (opening 0)
const PHONE_PRODUCT_ID = '13000000-0000-4000-8000-000000000001'; // Samsung Galaxy A16
const PHONE_VARIANT_ID = '14000000-0000-4000-8000-000000000001'; // 8GB/128GB Black
const ACC_PRODUCT_ID = '13000000-0000-4000-8000-000000000013'; // Oraimo Fast Charger 25W
const ACC_VARIANT_ID = '14000000-0000-4000-8000-000000000018'; // 25W USB-C Black

let failures = 0;
let checks = 0;
function check(name, cond, detail = '') {
  checks++;
  if (cond) {
    console.log(`  PASS  ${name}${detail ? ` — ${detail}` : ''}`);
  } else {
    failures++;
    console.log(`  FAIL  ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

async function req(method, path, token, body) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let json = null;
  try {
    json = JSON.parse(text);
  } catch {
    /* non-JSON */
  }
  return { status: res.status, json, text };
}

// Ledger balance, computed order-independently: the seed writes two
// entries with the same entry_date/created_at, so "latest entry" is
// ambiguous there. Customer balance = SUM(debit - credit); supplier
// payable = SUM(credit - debit).
function ledgerBalance(ledger, side = 'customer') {
  const entries = Array.isArray(ledger) ? ledger : (ledger?.entries ?? ledger?.ledger ?? []);
  if (!Array.isArray(ledger) && typeof ledger?.balance === 'number') return ledger.balance;
  return entries.reduce(
    (sum, e) => sum + (side === 'supplier' ? e.credit - e.debit : e.debit - e.credit),
    0,
  );
}
function ledgerEntries(ledger) {
  if (Array.isArray(ledger)) return ledger;
  return ledger?.entries ?? ledger?.ledger ?? [];
}
function makeImei(base14) {
  let sum = 0;
  for (let i = 0; i < base14.length; i++) {
    let d = Number(base14[i]);
    if ((base14.length - i) % 2 === 0) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
  }
  return base14 + String((10 - (sum % 10)) % 10);
}

const IMEI1 = makeImei('86991123456789');
const IMEI2 = makeImei('86991123456790');
console.log(`IMEIs: ${IMEI1}, ${IMEI2}`);

const admin = await req('POST', '/api/v1/login', null, {
  phone: '+923299966771',
  password: 'admin123',
});
if (admin.status !== 200) {
  console.log('FAIL login admin', admin.status, admin.text);
  process.exit(1);
}
const token = admin.json.data.accessToken;
const adminId = admin.json.data.user.id;
console.log(`Logged in as admin ${admin.json.data.user.name} (${adminId})`);

// --- Pre-state ---------------------------------------------------------------
const dashBefore = (await req('GET', '/api/v1/reports/dashboard', token)).json.data;
const plBefore = (
  await req('GET', '/api/v1/reports/profit-loss?from=2026-11-01&to=2026-11-30', token)
).json.data;
const phoneVariantBefore = (await req('GET', `/api/v1/products/${PHONE_PRODUCT_ID}`, token)).json
  .data.variants.find((v) => v.id === PHONE_VARIANT_ID);
const accVariantBefore = (await req('GET', `/api/v1/products/${ACC_PRODUCT_ID}`, token)).json.data
  .variants.find((v) => v.id === ACC_VARIANT_ID);
const supplierBefore = (await req('GET', `/api/v1/suppliers/${SUPPLIER_ID}/ledger`, token)).json.data;
console.log(
  `Pre-state: phone variant qty=${phoneVariantBefore.quantity}, acc variant qty=${accVariantBefore.quantity}, ` +
    `supplier payable=${ledgerBalance(supplierBefore, 'supplier')}, ` +
    `dashboard today_sales=${dashBefore.today_sales}, month_profit=${dashBefore.month_profit}`,
);

// --- (a) Purchase: 2 phones + 5 accessories, unpaid --------------------------
console.log('\n(a) Create purchase (2 phones + 5 accessories, unpaid)');
const purchase = await req('POST', '/api/v1/purchases', token, {
  supplierId: SUPPLIER_ID,
  supplierInvoiceNo: 'E2E-001',
  items: [
    { productId: PHONE_PRODUCT_ID, variantId: PHONE_VARIANT_ID, imei1: IMEI1, quantity: 1, unitCost: 48500 },
    { productId: PHONE_PRODUCT_ID, variantId: PHONE_VARIANT_ID, imei1: IMEI2, quantity: 1, unitCost: 48500 },
    { productId: ACC_PRODUCT_ID, variantId: ACC_VARIANT_ID, quantity: 5, unitCost: 1400 },
  ],
  paidAmount: 0,
});
check('purchase created (201)', purchase.status === 201, `status=${purchase.status} ${purchase.text.slice(0, 200)}`);
const pur = purchase.json?.data;
if (pur) {
  check('purchase grand_total 104000', pur.grand_total === 104000, `got ${pur.grand_total}`);
  check('purchase balance_due 104000', pur.balance_due === 104000, `got ${pur.balance_due}`);
  const imei1 = (await req('GET', `/api/v1/imei/${IMEI1}`, token)).json.data;
  const imei2 = (await req('GET', `/api/v1/imei/${IMEI2}`, token)).json.data;
  check('IMEI 1 available after purchase', imei1.status === 'available', `status=${imei1.status}`);
  check('IMEI 2 available after purchase', imei2.status === 'available', `status=${imei2.status}`);
  const phoneVariantAfter = (await req('GET', `/api/v1/products/${PHONE_PRODUCT_ID}`, token)).json
    .data.variants.find((v) => v.id === PHONE_VARIANT_ID);
  check('phone variant qty unchanged by phone purchase (IMEI-tracked)', phoneVariantAfter.quantity === phoneVariantBefore.quantity, `qty=${phoneVariantAfter.quantity}`);
  const accVariantAfter = (await req('GET', `/api/v1/products/${ACC_PRODUCT_ID}`, token)).json.data
    .variants.find((v) => v.id === ACC_VARIANT_ID);
  check('accessory variant qty +5', accVariantAfter.quantity === accVariantBefore.quantity + 5, `qty=${accVariantAfter.quantity}`);
  const supplierAfter = (await req('GET', `/api/v1/suppliers/${SUPPLIER_ID}/ledger`, token)).json.data;
  const supBal = ledgerBalance(supplierAfter, 'supplier');
  const supBalBefore = ledgerBalance(supplierBefore, 'supplier');
  check('supplier payable +104000', supBal === supBalBefore + 104000, `before=${supBalBefore} after=${supBal}`);
  var imeiItemId1 = imei1.id;
  var purchaseId = pur.id;
}

// --- (b) Sell one phone, partial payment --------------------------------------
console.log('\n(b) Sell one phone, partial payment (54000, paid 30000)');
const sale = await req('POST', '/api/v1/sales', token, {
  customerId: CUSTOMER_ID,
  items: [{ variantId: PHONE_VARIANT_ID, imeiItemId: imeiItemId1, quantity: 1, unitPrice: 54000 }],
  paymentMethod: 'partial',
  paidAmount: 30000,
});
check('sale created (201)', sale.status === 201, `status=${sale.status} ${sale.text.slice(0, 300)}`);
const s = sale.json?.data;
if (s) {
  check('sale grand_total 54000', s.grand_total === 54000, `got ${s.grand_total}`);
  check('sale paid 30000', s.paid_amount === 30000, `got ${s.paid_amount}`);
  check('sale balance_due 24000', s.balance_due === 24000, `got ${s.balance_due}`);
  check('sale payment_status partial', s.payment_status === 'partial', `got ${s.payment_status}`);
  const imei1 = (await req('GET', `/api/v1/imei/${IMEI1}`, token)).json.data;
  check('IMEI sold after sale', imei1.status === 'sold', `status=${imei1.status}`);
  check('IMEI sold_sale_id set', imei1.sold_sale_id === s.id, `sold_sale_id=${imei1.sold_sale_id}`);
  const ledger = (await req('GET', `/api/v1/customers/${CUSTOMER_ID}/ledger`, token)).json.data;
  const custBal = ledgerBalance(ledger);
  check('customer ledger balance 24000 after partial sale', custBal === 24000, `balance=${custBal}`);
  var saleId = s.id;
  var saleItemId = s.items?.[0]?.id;
}

// --- (c) Invoice ---------------------------------------------------------------
console.log('\n(c) Fetch invoice');
const invoice = await req('GET', `/api/v1/sales/${saleId}/invoice`, token);
check('invoice fetched (200)', invoice.status === 200, `status=${invoice.status}`);
if (invoice.json?.data) {
  const inv = invoice.json.data;
  check('invoice has sale + items', !!inv.sale || !!inv.items || !!inv.invoice_no, JSON.stringify(inv).slice(0, 200));
}

// --- (d) Return the sold phone --------------------------------------------------
console.log('\n(d) Return the sold phone');
const ret = await req('POST', `/api/v1/sales/${saleId}/return`, token, {
  items: [{ saleItemId, quantity: 1, reason: 'E2E return check' }],
});
check('return accepted (200/201)', ret.status === 200 || ret.status === 201, `status=${ret.status} ${ret.text.slice(0, 300)}`);
const rs = ret.json?.data;
if (rs) {
  check('sale status returned', rs.status === 'returned', `status=${rs.status}`);
  check('sale paid 0 after return', Number(rs.paid_amount) === 0, `paid=${rs.paid_amount}`);
  check('sale balance_due 0 after return', Number(rs.balance_due) === 0, `due=${rs.balance_due}`);
  check('sale grand_total 0 after full return (revenue reversed)', Number(rs.grand_total) === 0, `grand_total=${rs.grand_total}`);
  const imei1 = (await req('GET', `/api/v1/imei/${IMEI1}`, token)).json.data;
  check('IMEI available again after return', imei1.status === 'available', `status=${imei1.status}`);
  check('IMEI sold_sale_id cleared', imei1.sold_sale_id == null, `sold_sale_id=${imei1.sold_sale_id}`);
  const ledger = (await req('GET', `/api/v1/customers/${CUSTOMER_ID}/ledger`, token)).json.data;
  const custBal = ledgerBalance(ledger);
  check('customer ledger balance 0 after return', custBal === 0, `balance=${custBal}`);
  const entries = ledgerEntries(ledger);
  console.log(`  ledger entries: ${entries.map((e) => `${e.reference_type}:${e.debit}/${e.credit}`).join(', ')}`);
}

// --- (e) Reports -----------------------------------------------------------------
console.log('\n(e) Reports after full return');
const dashAfter = (await req('GET', '/api/v1/reports/dashboard', token)).json.data;
const plAfter = (
  await req('GET', '/api/v1/reports/profit-loss?from=2026-11-01&to=2026-11-30', token)
).json.data;
check('dashboard today_sales unchanged by returned sale', Number(dashAfter.today_sales) === Number(dashBefore.today_sales), `before=${dashBefore.today_sales} after=${dashAfter.today_sales}`);
check('dashboard month_profit unchanged by returned sale', Number(dashAfter.month_profit) === Number(dashBefore.month_profit), `before=${dashBefore.month_profit} after=${dashAfter.month_profit}`);
check('dashboard total_udhaar unchanged', Number(dashAfter.total_udhaar) === Number(dashBefore.total_udhaar), `before=${dashBefore.total_udhaar} after=${dashAfter.total_udhaar}`);
check('P&L revenue unchanged by returned sale', Number(plAfter.revenue) === Number(plBefore.revenue), `before=${plBefore.revenue} after=${plAfter.revenue}`);
check('P&L gross profit unchanged by returned sale', Number(plAfter.grossProfit) === Number(plBefore.grossProfit), `before=${plBefore.grossProfit} after=${plAfter.grossProfit}`);
console.log(`  P&L: revenue=${plAfter.revenue} grossProfit=${plAfter.grossProfit} bills=${plAfter.bills}`);

console.log(`\n${checks - failures}/${checks} checks passed, ${failures} failed.`);
process.exit(failures > 0 ? 1 : 0);
