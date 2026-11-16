// Live edge-case checks against the running backend + PostgreSQL shopdb.
// Round 3 verification (Worker V). Run with:  node scripts/edge-cases-live.mjs
// Requires: backend running on http://localhost:3000 (seed + E2E scenario
// data present is fine — each case uses its own IMEIs/stock).
// Exits non-zero if any check fails.
const BASE = 'http://localhost:3000';

const CUSTOMER_ID = '16000000-0000-4000-8000-000000000001'; // Ahmed Raza
const PHONE_VARIANT_ID = '14000000-0000-4000-8000-000000000001'; // A16 8/128 Black (min 52000)
const ACC_VARIANT_ID = '14000000-0000-4000-8000-000000000018'; // Oraimo charger (qty 54 after E2E)
const ACC_PRODUCT_ID = '13000000-0000-4000-8000-000000000013';
const PHONE_PRODUCT_ID = '13000000-0000-4000-8000-000000000001';

let failures = 0;
let checks = 0;
function check(name, cond, detail = '') {
  checks++;
  if (cond) console.log(`  PASS  ${name}${detail ? ` — ${detail}` : ''}`);
  else {
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
  } catch { /* non-JSON */ }
  return { status: res.status, json, text };
}

function ledgerBalance(ledger, side = 'customer') {
  const entries = Array.isArray(ledger) ? ledger : (ledger?.entries ?? ledger?.ledger ?? []);
  if (!Array.isArray(ledger) && typeof ledger?.balance === 'number') return ledger.balance;
  return entries.reduce(
    (sum, e) => sum + (side === 'supplier' ? e.credit - e.debit : e.debit - e.credit),
    0,
  );
}

async function variantQty(token, productId, variantId) {
  const p = await req('GET', `/api/v1/products/${productId}`, token);
  return p.json.data.variants.find((v) => v.id === variantId).quantity;
}

const adminLogin = await req('POST', '/api/v1/login', null, { phone: '+923299966771', password: 'admin123' });
if (adminLogin.status !== 200) { console.log('FAIL admin login', adminLogin.status, adminLogin.text); process.exit(1); }
const token = adminLogin.json.data.accessToken;
const adminId = adminLogin.json.data.user.id;
const cashierLogin = await req('POST', '/api/v1/login', null, { phone: '+923001234567', password: 'cashier123' });
const cashierToken = cashierLogin.status === 200 ? cashierLogin.json.data.accessToken : null;
console.log(`Admin + cashier logged in (cashier token: ${cashierToken ? 'yes' : 'NO — ' + cashierLogin.text})`);

// --- 1. Duplicate IMEI rejected (409) ------------------------------------------
console.log('\n1. Duplicate IMEI rejected');
const dup = await req('POST', '/api/v1/purchases', token, {
  supplierId: '17000000-0000-4000-8000-000000000001',
  supplierInvoiceNo: 'EDGE-DUP',
  items: [{ productId: PHONE_PRODUCT_ID, variantId: PHONE_VARIANT_ID, imei1: '869911234567890', quantity: 1, unitCost: 48500 }],
  paidAmount: 0,
});
check('duplicate IMEI purchase -> 409', dup.status === 409, `status=${dup.status} ${dup.text.slice(0, 160)}`);

// --- 2. Accessory sale return restores stock + totals ---------------------------
console.log('\n2. Accessory sale return restores stock');
const qtyBefore = await variantQty(token, ACC_PRODUCT_ID, ACC_VARIANT_ID);
const accSale = await req('POST', '/api/v1/sales', token, {
  customerId: CUSTOMER_ID,
  items: [{ variantId: ACC_VARIANT_ID, quantity: 2, unitPrice: 2000 }],
  paymentMethod: 'cash',
  paidAmount: 4000,
});
check('accessory sale created', accSale.status === 201, `status=${accSale.status}`);
const accSaleId = accSale.json?.data?.id;
const accItemId = accSale.json?.data?.items?.[0]?.id;
if (accSaleId) {
  const qtyAfterSale = await variantQty(token, ACC_PRODUCT_ID, ACC_VARIANT_ID);
  check('accessory qty -2 after sale', qtyAfterSale === qtyBefore - 2, `before=${qtyBefore} after=${qtyAfterSale}`);
  const accRet = await req('POST', `/api/v1/sales/${accSaleId}/return`, token, {
    items: [{ saleItemId: accItemId, quantity: 1, reason: 'edge case' }],
  });
  check('accessory return accepted', accRet.status === 200, `status=${accRet.status}`);
  const qtyAfterReturn = await variantQty(token, ACC_PRODUCT_ID, ACC_VARIANT_ID);
  check('accessory qty +1 after return', qtyAfterReturn === qtyBefore - 1, `qty=${qtyAfterReturn}`);
  check('sale grand_total 2000 after partial return', Number(accRet.json?.data?.grand_total) === 2000, `grand_total=${accRet.json?.data?.grand_total}`);
  check('sale status partially_returned', accRet.json?.data?.status === 'partially_returned', `status=${accRet.json?.data?.status}`);
  const led = (await req('GET', `/api/v1/customers/${CUSTOMER_ID}/ledger`, token)).json.data;
  check('customer ledger still 0 (fully-paid return)', ledgerBalance(led) === 0, `balance=${ledgerBalance(led)}`);
  // Double return of the same line must be rejected (only 1 left).
  const doubleRet = await req('POST', `/api/v1/sales/${accSaleId}/return`, token, {
    items: [{ saleItemId: accItemId, quantity: 2, reason: 'double return' }],
  });
  check('double return rejected (400)', doubleRet.status === 400, `status=${doubleRet.status} ${doubleRet.text.slice(0, 160)}`);
}

// --- 3. Partial payment leaves correct remaining balance -----------------------
console.log('\n3. Partial payment + udhaar recovery');
const partSale = await req('POST', '/api/v1/sales', token, {
  customerId: CUSTOMER_ID,
  items: [{ variantId: ACC_VARIANT_ID, quantity: 5, unitPrice: 2000 }],
  paymentMethod: 'partial',
  paidAmount: 4000,
});
check('partial sale created', partSale.status === 201, `status=${partSale.status}`);
const partSaleId = partSale.json?.data?.id;
if (partSaleId) {
  check('partial sale balance_due 6000', partSale.json.data.balance_due === 6000, `due=${partSale.json.data.balance_due}`);
  const led1 = (await req('GET', `/api/v1/customers/${CUSTOMER_ID}/ledger`, token)).json.data;
  check('ledger balance 6000 after partial sale', ledgerBalance(led1) === 6000, `balance=${ledgerBalance(led1)}`);
  const pay = await req('POST', `/api/v1/sales/${partSaleId}/payments`, token, { amount: 6000, method: 'cash' });
  check('udhaar recovery payment accepted', pay.status === 200 || pay.status === 201, `status=${pay.status} ${pay.text.slice(0, 160)}`);
  const after = (await req('GET', `/api/v1/sales/${partSaleId}`, token)).json.data;
  check('sale balance_due 0 after recovery', Number(after.balance_due) === 0, `due=${after.balance_due}`);
  check('sale payment_status paid', after.payment_status === 'paid', `status=${after.payment_status}`);
  const led2 = (await req('GET', `/api/v1/customers/${CUSTOMER_ID}/ledger`, token)).json.data;
  check('ledger balance 0 after recovery', ledgerBalance(led2) === 0, `balance=${ledgerBalance(led2)}`);
}

// --- 4. Installment overdue flagged ---------------------------------------------
console.log('\n4. Installment overdue flagged');
const overdueBefore = await req('GET', '/api/v1/installments/overdue', token);
check('overdue endpoint 200', overdueBefore.status === 200, `status=${overdueBefore.status}`);
const overdueList = overdueBefore.json?.data ?? [];
check('seed overdue installment present (due 2026-11-15)', overdueList.some((r) => String(r.due_date).startsWith('2026-11-15')), `count=${overdueList.length}`);
// Create a plan with past start date on a fresh partial sale.
const instSale = await req('POST', '/api/v1/sales', token, {
  customerId: CUSTOMER_ID,
  items: [{ variantId: ACC_VARIANT_ID, quantity: 2, unitPrice: 2000 }],
  paymentMethod: 'partial',
  paidAmount: 1000,
});
const instSaleId = instSale.json?.data?.id;
if (instSaleId) {
  const plan = await req('POST', '/api/v1/installments', token, {
    saleId: instSaleId,
    installmentCount: 3,
    startDate: '2026-10-01',
  });
  check('installment plan created', plan.status === 200 || plan.status === 201, `status=${plan.status} ${plan.text.slice(0, 200)}`);
  const overdueAfter = (await req('GET', '/api/v1/installments/overdue', token)).json.data ?? [];
  const mine = overdueAfter.filter((r) => r.sale_id === instSaleId || r.customer_id === CUSTOMER_ID);
  check('new past-due installments flagged overdue', mine.length >= 2, `overdue rows for this sale=${mine.length}, dues=${mine.map((r) => String(r.due_date).slice(0, 10)).join(',')}`);
}

// --- 5. Offline sale then sync: no double-apply --------------------------------
console.log('\n5. Offline sale sync (same clientUuid twice)');
const clientUuid = crypto.randomUUID();
const salesBefore = (await req('GET', '/api/v1/sales?limit=1', token)).json;
const totalBefore = salesBefore.meta?.total;
const push1 = await req('POST', '/api/v1/sync/push', token, {
  deviceId: 'edge-test-device',
  sales: [{
    clientUuid,
    customerId: CUSTOMER_ID,
    items: [{ variantId: PHONE_VARIANT_ID, imei1: '869911234567907', quantity: 1, unitPrice: 54000 }],
    paidAmount: 54000,
    paymentMethod: 'cash',
  }],
});
check('first push accepted 1', push1.json?.data?.accepted?.length === 1, `status=${push1.status} ${push1.text.slice(0, 200)}`);
const salesAfter1 = (await req('GET', '/api/v1/sales?limit=1', token)).json;
const totalAfter1 = salesAfter1.meta?.total;
check('sales total +1 after first push', totalAfter1 === totalBefore + 1, `before=${totalBefore} after=${totalAfter1}`);
const push2 = await req('POST', '/api/v1/sync/push', token, {
  deviceId: 'edge-test-device',
  sales: [{
    clientUuid,
    customerId: CUSTOMER_ID,
    items: [{ variantId: PHONE_VARIANT_ID, imei1: '869911234567907', quantity: 1, unitPrice: 54000 }],
    paidAmount: 54000,
    paymentMethod: 'cash',
  }],
});
check('second push skipped already_synced', push2.json?.data?.skipped?.[0]?.reason === 'already_synced', `status=${push2.status} ${push2.text.slice(0, 200)}`);
check('second push accepted 0', (push2.json?.data?.accepted?.length ?? -1) === 0, `accepted=${push2.json?.data?.accepted?.length}`);
const salesAfter2 = (await req('GET', '/api/v1/sales?limit=1', token)).json;
const totalAfter2 = salesAfter2.meta?.total;
check('sales total unchanged after second push', totalAfter2 === totalAfter1, `after1=${totalAfter1} after2=${totalAfter2}`);
const syncedSaleId = push1.json?.data?.accepted?.[0]?.id;
if (syncedSaleId) {
  const synced = (await req('GET', `/api/v1/sales/${syncedSaleId}`, token)).json.data;
  check('synced sale has the IMEI sold', synced.items?.[0]?.imei1 === '869911234567907', `imei=${synced.items?.[0]?.imei1}`);
}

// --- 6. Cashier cannot see cost prices ------------------------------------------
console.log('\n6. Cashier cost visibility');
if (cashierToken) {
  const prods = await req('GET', '/api/v1/products?limit=5', cashierToken);
  const body = JSON.stringify(prods.json);
  check('cashier products: no purchase_price', !body.includes('purchase_price'), `status=${prods.status}`);
  check('cashier products: no purchase_cost', !body.includes('purchase_cost'));
  check('cashier products: no min_price', !body.includes('min_price'));
  check('cashier products: no profit field', !body.includes('"profit"'));
  const one = await req('GET', `/api/v1/products/${PHONE_PRODUCT_ID}`, cashierToken);
  const oneBody = JSON.stringify(one.json);
  check('cashier single product: no purchase_price', !oneBody.includes('purchase_price'));
  check('cashier single product: no min_price', !oneBody.includes('min_price'));
  if (syncedSaleId) {
    const saleAsCashier = await req('GET', `/api/v1/sales/${syncedSaleId}`, cashierToken);
    const saleBody = JSON.stringify(saleAsCashier.json);
    check('cashier sale: no purchase_cost', !saleBody.includes('purchase_cost'));
    check('cashier sale: no profit field', !saleBody.includes('"profit"'));
  }
  const prodsAdmin = await req('GET', '/api/v1/products?limit=1', token);
  check('admin products DO include purchase_price (control)', JSON.stringify(prodsAdmin.json).includes('purchase_price'));
} else {
  check('cashier login', false, 'no cashier token');
}

// --- 7. Below-min-price sale needs admin approval -------------------------------
console.log('\n7. Below-min-price approval');
const cheap = await req('POST', '/api/v1/sales', token, {
  customerId: CUSTOMER_ID,
  items: [{ variantId: PHONE_VARIANT_ID, imeiItemId: (await req('GET', '/api/v1/imei/860123456789012', token)).json?.data?.id, quantity: 1, unitPrice: 51000 }],
  paymentMethod: 'cash',
  paidAmount: 51000,
});
check('below-min sale without approval -> 403', cheap.status === 403, `status=${cheap.status} ${cheap.text.slice(0, 200)}`);
check('403 code is MIN_PRICE_APPROVAL_REQUIRED', cheap.json?.error?.code === 'MIN_PRICE_APPROVAL_REQUIRED', `code=${cheap.json?.error?.code}`);
const cheapOk = await req('POST', '/api/v1/sales', token, {
  customerId: CUSTOMER_ID,
  items: [{ variantId: PHONE_VARIANT_ID, imeiItemId: (await req('GET', '/api/v1/imei/860123456789012', token)).json?.data?.id, quantity: 1, unitPrice: 51000 }],
  paymentMethod: 'cash',
  paidAmount: 51000,
  adminApprovedBy: adminId,
});
check('below-min sale with admin approval -> 201', cheapOk.status === 201, `status=${cheapOk.status} ${cheapOk.text.slice(0, 200)}`);
// A cashier (non owner/manager) approval must NOT work.
const cashierId = cashierLogin.json?.data?.user?.id;
if (cashierId) {
  const cheapBad = await req('POST', '/api/v1/sales', token, {
    items: [{ variantId: PHONE_VARIANT_ID, imeiItemId: (await req('GET', '/api/v1/imei/860123456789013', token)).json?.data?.id, quantity: 1, unitPrice: 51000 }],
    paymentMethod: 'cash',
    paidAmount: 51000,
    adminApprovedBy: cashierId,
  });
  check('cashier approval rejected (403)', cheapBad.status === 403, `status=${cheapBad.status} ${cheapBad.text.slice(0, 160)}`);
}

// --- 8. Supplier payable display is the SUM-based balance ---------------------
console.log('\n8. Supplier payable display (SUM-based, seed tie-proof)');
const supList = (await req('GET', '/api/v1/suppliers', token)).json.data;
const hassan = (supList.rows ?? supList).find((s) => s.id === '17000000-0000-4000-8000-000000000001');
check('supplier list: Hassan payable 348500 (244500 seed + 104000 E2E)', Number(hassan?.payable_balance) === 348500, `payable_balance=${hassan?.payable_balance}`);
const supPay = (await req('GET', '/api/v1/reports/supplier-payables', token)).json.data;
const hassanPay = (supPay.rows ?? supPay).find((s) => s.id === '17000000-0000-4000-8000-000000000001');
check('supplier-payables report: Hassan 348500', Number(hassanPay?.balance) === 348500, `balance=${hassanPay?.balance}`);
const pendUdhaar = (await req('GET', '/api/v1/reports/pending-udhaar', token)).json.data;
const pendList = pendUdhaar.rows ?? pendUdhaar;
check('pending-udhaar report is a list', Array.isArray(pendList), `count=${pendList.length}`);

console.log(`\n${checks - failures}/${checks} checks passed, ${failures} failed.`);
process.exit(failures > 0 ? 1 : 0);
