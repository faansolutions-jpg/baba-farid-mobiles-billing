/// Report repository: dashboard totals, sales series, P&L, stock
/// valuation, brand/model sales, best sellers, dead stock, pending
/// udhaar, supplier payables and IMEI history.
///
/// All queries are read-only aggregates over the local drift database.
/// Money is integer whole PKR.
library;

import 'package:drift/drift.dart';

import '../database/app_database.dart' as db;

/// Dashboard headline numbers for a period.
class DashboardTotals {
  final int totalRevenue;
  final int totalProfit;
  final int totalExpenses;
  final int totalPurchases;
  final int pendingUdhaar;
  final int supplierPayables;
  final int salesCount;
  final int openRepairs;
  final int availablePhones;

  const DashboardTotals({
    this.totalRevenue = 0,
    this.totalProfit = 0,
    this.totalExpenses = 0,
    this.totalPurchases = 0,
    this.pendingUdhaar = 0,
    this.supplierPayables = 0,
    this.salesCount = 0,
    this.openRepairs = 0,
    this.availablePhones = 0,
  });
}

/// One day (or week/month bucket) of sales.
class SalesSummary {
  final DateTime date;
  final int salesCount;
  final int revenue;
  final int profit;

  const SalesSummary({
    required this.date,
    this.salesCount = 0,
    this.revenue = 0,
    this.profit = 0,
  });
}

/// Profit & loss for a period.
class ProfitLoss {
  final int revenue;
  final int costOfGoods;
  final int grossProfit;
  final int expenses;
  final int serviceCommission;
  final int netProfit;

  const ProfitLoss({
    this.revenue = 0,
    this.costOfGoods = 0,
    this.grossProfit = 0,
    this.expenses = 0,
    this.serviceCommission = 0,
    this.netProfit = 0,
  });
}

/// Stock valuation (cost vs. sale value).
class StockValuation {
  final int phoneCostValue;
  final int phoneSaleValue;
  final int phoneCount;
  final int accessoryCostValue;
  final int accessorySaleValue;
  final int accessoryUnits;

  const StockValuation({
    this.phoneCostValue = 0,
    this.phoneSaleValue = 0,
    this.phoneCount = 0,
    this.accessoryCostValue = 0,
    this.accessorySaleValue = 0,
    this.accessoryUnits = 0,
  });

  int get totalCostValue => phoneCostValue + accessoryCostValue;
  int get totalSaleValue => phoneSaleValue + accessorySaleValue;
}

class BrandSales {
  final String brandName;
  final int quantity;
  final int revenue;
  final int profit;

  const BrandSales({
    required this.brandName,
    this.quantity = 0,
    this.revenue = 0,
    this.profit = 0,
  });
}

class BestSeller {
  final String productName;
  final String variantName;
  final int quantity;
  final int revenue;

  const BestSeller({
    required this.productName,
    this.variantName = '',
    this.quantity = 0,
    this.revenue = 0,
  });
}

class DeadStockItem {
  final String productName;
  final String variantName;
  final String? imei1;
  final int quantity;
  final DateTime? lastActivity;
  final int daysUnsold;

  const DeadStockItem({
    required this.productName,
    this.variantName = '',
    this.imei1,
    this.quantity = 0,
    this.lastActivity,
    this.daysUnsold = 0,
  });
}

class PendingUdhaar {
  final String customerId;
  final String customerName;
  final String phone;
  final int balance;

  const PendingUdhaar({
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.balance,
  });
}

class SupplierPayable {
  final String supplierId;
  final String supplierName;
  final String phone;
  final int payable;

  const SupplierPayable({
    required this.supplierId,
    required this.supplierName,
    required this.phone,
    required this.payable,
  });
}

/// One event in a phone's life (purchase -> sale -> return ...).
class ImeiHistoryEntry {
  final DateTime date;
  final String event;
  final String detail;
  final String? saleId;

  const ImeiHistoryEntry({
    required this.date,
    required this.event,
    required this.detail,
    this.saleId,
  });
}

abstract class ReportRepository {
  Future<DashboardTotals> dashboardTotals({
    String? branchId,
    DateTime? from,
    DateTime? to,
  });
  Future<List<SalesSummary>> dailySales(DateTime from, DateTime to);
  Future<List<SalesSummary>> weeklySales(DateTime from, DateTime to);
  Future<List<SalesSummary>> monthlySales(DateTime from, DateTime to);
  Future<ProfitLoss> profitAndLoss(DateTime from, DateTime to);
  Future<StockValuation> stockValuation();
  Future<List<BrandSales>> brandSales(DateTime from, DateTime to);
  Future<List<BestSeller>> bestSellers({
    DateTime? from,
    DateTime? to,
    int limit = 10,
  });
  Future<List<DeadStockItem>> deadStock({int days = 60});
  Future<List<PendingUdhaar>> pendingUdhaar();
  Future<List<SupplierPayable>> supplierPayables();
  Future<List<ImeiHistoryEntry>> imeiHistory(String imei1);
}

class DriftReportRepository implements ReportRepository {
  final db.AppDatabase database;

  DriftReportRepository(this.database);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<int> _sum(String sql, List<Variable> variables) async {
    final row = await database.customSelect(sql, variables: variables).getSingle();
    return row.read<int>('total');
  }

  @override
  Future<DashboardTotals> dashboardTotals({
    String? branchId,
    DateTime? from,
    DateTime? to,
  }) async {
    final start = from ?? DateTime.now().subtract(const Duration(days: 30));
    final end = to ?? DateTime.now();
    final revenue = await _sum(
      "SELECT COALESCE(SUM(grand_total), 0) AS total FROM sales "
      "WHERE sale_date >= ? AND sale_date <= ? AND status != 'cancelled'",
      [Variable.withDateTime(start), Variable.withDateTime(end)],
    );
    final profit = await _sum(
      'SELECT COALESCE(SUM(profit), 0) AS total FROM sale_items '
      'WHERE sale_id IN (SELECT id FROM sales WHERE sale_date >= ? '
      "AND sale_date <= ? AND status != 'cancelled')",
      [Variable.withDateTime(start), Variable.withDateTime(end)],
    );
    final expenses = await _sum(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses '
      'WHERE expense_date >= ? AND expense_date <= ?',
      [Variable.withDateTime(start), Variable.withDateTime(end)],
    );
    final purchases = await _sum(
      'SELECT COALESCE(SUM(grand_total), 0) AS total FROM purchases '
      "WHERE purchase_date >= ? AND purchase_date <= ? AND status != 'cancelled'",
      [Variable.withDateTime(start), Variable.withDateTime(end)],
    );
    final salesCountRow = await database.customSelect(
      "SELECT COUNT(*) AS cnt FROM sales WHERE sale_date >= ? AND "
      "sale_date <= ? AND status != 'cancelled'",
      variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
    ).getSingle();
    // Pending udhaar / payables as net SUMs per person (not the
    // "latest balance_after" row): entries sharing an entryDate
    // millisecond made the MAX(entry_date) join return several rows
    // whose balances were then summed (a sale + immediate return once
    // read 30000 instead of 6000).
    final udhaar = await _sum(
      'SELECT COALESCE(SUM(net), 0) AS total FROM '
      '(SELECT SUM(debit - credit) AS net FROM ledger_entries '
      "WHERE side = 'customer' GROUP BY customer_id) t WHERE net > 0",
      [],
    );
    final payables = await _sum(
      'SELECT COALESCE(SUM(net), 0) AS total FROM '
      '(SELECT SUM(credit - debit) AS net FROM ledger_entries '
      "WHERE side = 'supplier' GROUP BY supplier_id) t WHERE net > 0",
      [],
    );
    final repairsRow = await database.customSelect(
      "SELECT COUNT(*) AS cnt FROM repairs WHERE status IN "
      "('received', 'in_progress', 'ready')",
    ).getSingle();
    final phonesRow = await database.customSelect(
      "SELECT COUNT(*) AS cnt FROM imei_items WHERE status = 'available'",
    ).getSingle();
    return DashboardTotals(
      totalRevenue: revenue,
      totalProfit: profit,
      totalExpenses: expenses,
      totalPurchases: purchases,
      pendingUdhaar: udhaar,
      supplierPayables: payables,
      salesCount: salesCountRow.read<int>('cnt'),
      openRepairs: repairsRow.read<int>('cnt'),
      availablePhones: phonesRow.read<int>('cnt'),
    );
  }

  Future<List<SalesSummary>> _salesSeries(
      DateTime from, DateTime to, String bucket) async {
    // sale_date is stored as epoch milliseconds; bucket by calendar day
    // (daily), ISO week (weekly) or month (monthly) via SQLite date().
    final expr = switch (bucket) {
      'week' => "strftime('%Y-%W', sale_date / 1000, 'unixepoch')",
      'month' => "strftime('%Y-%m', sale_date / 1000, 'unixepoch')",
      _ => "date(sale_date / 1000, 'unixepoch')",
    };
    final rows = await database.customSelect(
      'SELECT $expr AS bucket, COUNT(*) AS cnt, '
      'COALESCE(SUM(grand_total), 0) AS revenue FROM sales '
      "WHERE sale_date >= ? AND sale_date <= ? AND status != 'cancelled' "
      'GROUP BY bucket ORDER BY bucket ASC',
      variables: [Variable.withDateTime(from), Variable.withDateTime(to)],
    ).get();
    final result = <SalesSummary>[];
    for (final row in rows) {
      final label = row.read<String>('bucket');
      DateTime date;
      if (bucket == 'month') {
        final parts = label.split('-');
        date = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      } else if (bucket == 'week') {
        // Label is 'YYYY-WW' (strftime %Y-%W). Approximate the bucket
        // date as the Monday of that week.
        final year = int.parse(label.substring(0, 4));
        final week = int.parse(label.substring(5));
        final jan1 = DateTime(year, 1, 1);
        final firstMonday =
            jan1.add(Duration(days: (8 - jan1.weekday) % 7));
        date = firstMonday.add(Duration(days: (week - 1) * 7));
      } else {
        date = DateTime.tryParse(label) ?? DateTime.now();
      }
      // Profit per bucket needs a second query (sale_items join).
      final profitRow = await database.customSelect(
        'SELECT COALESCE(SUM(si.profit), 0) AS total FROM sale_items si '
        'JOIN sales s ON s.id = si.sale_id WHERE '
        "$expr = ? AND s.status != 'cancelled'",
        variables: [Variable.withString(label)],
      ).getSingle();
      result.add(SalesSummary(
        date: date,
        salesCount: row.read<int>('cnt'),
        revenue: row.read<int>('revenue'),
        profit: profitRow.read<int>('total'),
      ));
    }
    return result;
  }

  @override
  Future<List<SalesSummary>> dailySales(DateTime from, DateTime to) =>
      _salesSeries(_day(from), _day(to), 'day');

  @override
  Future<List<SalesSummary>> weeklySales(DateTime from, DateTime to) =>
      _salesSeries(_day(from), _day(to), 'week');

  @override
  Future<List<SalesSummary>> monthlySales(DateTime from, DateTime to) =>
      _salesSeries(_day(from), _day(to), 'month');

  @override
  Future<ProfitLoss> profitAndLoss(DateTime from, DateTime to) async {
    final revenue = await _sum(
      "SELECT COALESCE(SUM(grand_total), 0) AS total FROM sales "
      "WHERE sale_date >= ? AND sale_date <= ? AND status != 'cancelled'",
      [Variable.withDateTime(from), Variable.withDateTime(to)],
    );
    // Cost of goods net of returns: a returned line's cost is no
    // longer a cost (its profit was already reversed on return, and
    // the bill total shrank too — without this a fully returned bill
    // showed revenue 0 against the full cost, i.e. negative profit).
    final cogs = await _sum(
      'SELECT COALESCE(SUM(si.purchase_cost * '
      '(si.quantity - COALESCE(r.returned_qty, 0))), 0) AS total '
      'FROM sale_items si JOIN sales s ON s.id = si.sale_id '
      'LEFT JOIN (SELECT sale_item_id, SUM(quantity) AS returned_qty '
      'FROM sale_returns GROUP BY sale_item_id) r '
      'ON r.sale_item_id = si.id '
      "WHERE s.sale_date >= ? AND s.sale_date <= ? AND s.status != 'cancelled'",
      [Variable.withDateTime(from), Variable.withDateTime(to)],
    );
    final expenses = await _sum(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses '
      'WHERE expense_date >= ? AND expense_date <= ?',
      [Variable.withDateTime(from), Variable.withDateTime(to)],
    );
    final commission = await _sum(
      'SELECT COALESCE(SUM(commission), 0) AS total FROM service_sales '
      'WHERE sale_date >= ? AND sale_date <= ?',
      [Variable.withDateTime(from), Variable.withDateTime(to)],
    );
    final gross = revenue - cogs;
    return ProfitLoss(
      revenue: revenue,
      costOfGoods: cogs,
      grossProfit: gross,
      expenses: expenses,
      serviceCommission: commission,
      netProfit: gross - expenses + commission,
    );
  }

  @override
  Future<StockValuation> stockValuation() async {
    final phones = await database.customSelect(
      'SELECT COUNT(*) AS cnt, COALESCE(SUM(purchase_price), 0) AS cost, '
      "COALESCE(SUM(sale_price), 0) AS sale FROM imei_items "
      "WHERE status = 'available'",
    ).getSingle();
    final accessories = await database.customSelect(
      'SELECT COALESCE(SUM(quantity), 0) AS units, '
      'COALESCE(SUM(quantity * purchase_price), 0) AS cost, '
      'COALESCE(SUM(quantity * sale_price), 0) AS sale '
      'FROM product_variants WHERE is_active = 1 AND quantity > 0',
    ).getSingle();
    return StockValuation(
      phoneCostValue: phones.read<int>('cost'),
      phoneSaleValue: phones.read<int>('sale'),
      phoneCount: phones.read<int>('cnt'),
      accessoryCostValue: accessories.read<int>('cost'),
      accessorySaleValue: accessories.read<int>('sale'),
      accessoryUnits: accessories.read<int>('units'),
    );
  }

  @override
  Future<List<BrandSales>> brandSales(DateTime from, DateTime to) async {
    final rows = await database.customSelect(
      'SELECT COALESCE(b.name, \'Unknown\') AS brand, '
      'COALESCE(SUM(si.quantity - COALESCE(r.returned_qty, 0)), 0) AS qty, '
      'COALESCE(SUM(si.total - COALESCE(r.refunded, 0)), 0) AS revenue, '
      'COALESCE(SUM(si.profit), 0) AS profit FROM sale_items si '
      'JOIN sales s ON s.id = si.sale_id '
      'LEFT JOIN (SELECT sale_item_id, SUM(quantity) AS returned_qty, '
      'SUM(refund_amount) AS refunded FROM sale_returns '
      'GROUP BY sale_item_id) r ON r.sale_item_id = si.id '
      'LEFT JOIN products p ON p.id = si.product_id '
      'LEFT JOIN brands b ON b.id = p.brand_id '
      "WHERE s.sale_date >= ? AND s.sale_date <= ? AND s.status != 'cancelled' "
      'GROUP BY b.name ORDER BY revenue DESC',
      variables: [Variable.withDateTime(from), Variable.withDateTime(to)],
    ).get();
    return rows
        .map((r) => BrandSales(
              brandName: r.read<String>('brand'),
              quantity: r.read<int>('qty'),
              revenue: r.read<int>('revenue'),
              profit: r.read<int>('profit'),
            ))
        .toList();
  }

  @override
  Future<List<BestSeller>> bestSellers({
    DateTime? from,
    DateTime? to,
    int limit = 10,
  }) async {
    final start = from ?? DateTime.now().subtract(const Duration(days: 30));
    final end = to ?? DateTime.now();
    final rows = await database.customSelect(
      'SELECT si.name_snapshot AS name, COALESCE(pv.name, \'\') AS variant, '
      'COALESCE(SUM(si.quantity - COALESCE(r.returned_qty, 0)), 0) AS qty, '
      'COALESCE(SUM(si.total - COALESCE(r.refunded, 0)), 0) AS revenue FROM sale_items si '
      'JOIN sales s ON s.id = si.sale_id '
      'LEFT JOIN (SELECT sale_item_id, SUM(quantity) AS returned_qty, '
      'SUM(refund_amount) AS refunded FROM sale_returns '
      'GROUP BY sale_item_id) r ON r.sale_item_id = si.id '
      'LEFT JOIN product_variants pv ON pv.id = si.variant_id '
      "WHERE s.sale_date >= ? AND s.sale_date <= ? AND s.status != 'cancelled' "
      'GROUP BY si.name_snapshot, pv.name '
      'ORDER BY qty DESC, revenue DESC LIMIT ?',
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
        Variable.withInt(limit),
      ],
    ).get();
    return rows
        .map((r) => BestSeller(
              productName: r.read<String>('name'),
              variantName: r.read<String>('variant'),
              quantity: r.read<int>('qty'),
              revenue: r.read<int>('revenue'),
            ))
        .toList();
  }

  @override
  Future<List<DeadStockItem>> deadStock({int days = 60}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final result = <DeadStockItem>[];
    // Phones: available IMEI items created before the cutoff that were
    // never sold (status available means never sold since creation).
    final phones = await database.customSelect(
      'SELECT i.imei1 AS imei, COALESCE(p.name, \'\') AS product, '
      'COALESCE(pv.name, \'\') AS variant, i.created_at AS created_at '
      'FROM imei_items i LEFT JOIN products p ON p.id = i.product_id '
      'LEFT JOIN product_variants pv ON pv.id = i.variant_id '
      "WHERE i.status = 'available' AND i.created_at < ?",
      variables: [Variable.withDateTime(cutoff)],
    ).get();
    for (final row in phones) {
      final created = row.read<DateTime>('created_at');
      result.add(DeadStockItem(
        productName: row.read<String>('product'),
        variantName: row.read<String>('variant'),
        imei1: row.read<String>('imei'),
        quantity: 1,
        lastActivity: created,
        daysUnsold: DateTime.now().difference(created).inDays,
      ));
    }
    // Accessories: variants with stock and no sale in the last N days.
    final accessories = await database.customSelect(
      'SELECT COALESCE(p.name, \'\') AS product, pv.name AS variant, '
      'pv.quantity AS qty, pv.updated_at AS updated_at FROM '
      'product_variants pv LEFT JOIN products p ON p.id = pv.product_id '
      'WHERE pv.is_active = 1 AND pv.quantity > 0 AND pv.id NOT IN '
      '(SELECT DISTINCT variant_id FROM sale_items si JOIN sales s '
      'ON s.id = si.sale_id WHERE s.sale_date >= ? '
      'AND si.variant_id IS NOT NULL)',
      variables: [Variable.withDateTime(cutoff)],
    ).get();
    for (final row in accessories) {
      final updated = row.read<DateTime>('updated_at');
      result.add(DeadStockItem(
        productName: row.read<String>('product'),
        variantName: row.read<String>('variant'),
        quantity: row.read<int>('qty'),
        lastActivity: updated,
        daysUnsold: DateTime.now().difference(updated).inDays,
      ));
    }
    result.sort((a, b) => b.daysUnsold.compareTo(a.daysUnsold));
    return result;
  }

  @override
  Future<List<PendingUdhaar>> pendingUdhaar() async {
    // Per-person net balance as SUM(debit - credit): the old
    // MAX(entry_date) join returned several rows (and stale balances)
    // when entries shared an entryDate millisecond.
    final rows = await database.customSelect(
      'SELECT c.id AS id, c.name AS name, c.phone AS phone, '
      't.net AS balance FROM customers c JOIN ('
      'SELECT customer_id, SUM(debit - credit) AS net FROM ledger_entries '
      "WHERE side = 'customer' GROUP BY customer_id) t "
      'ON t.customer_id = c.id WHERE t.net > 0 ORDER BY t.net DESC',
    ).get();
    return rows
        .map((r) => PendingUdhaar(
              customerId: r.read<String>('id'),
              customerName: r.read<String>('name'),
              phone: r.read<String>('phone'),
              balance: r.read<int>('balance'),
            ))
        .toList();
  }

  @override
  Future<List<SupplierPayable>> supplierPayables() async {
    // Per-supplier net payable as SUM(credit - debit) (same
    // MAX(entry_date) tie problem as pendingUdhaar above).
    final rows = await database.customSelect(
      'SELECT s.id AS id, s.name AS name, COALESCE(s.phone, \'\') AS phone, '
      't.net AS balance FROM suppliers s JOIN ('
      'SELECT supplier_id, SUM(credit - debit) AS net FROM ledger_entries '
      "WHERE side = 'supplier' GROUP BY supplier_id) t "
      'ON t.supplier_id = s.id WHERE t.net > 0 ORDER BY t.net DESC',
    ).get();
    return rows
        .map((r) => SupplierPayable(
              supplierId: r.read<String>('id'),
              supplierName: r.read<String>('name'),
              phone: r.read<String>('phone'),
              payable: r.read<int>('balance'),
            ))
        .toList();
  }

  @override
  Future<List<ImeiHistoryEntry>> imeiHistory(String imei1) async {
    final history = <ImeiHistoryEntry>[];
    final imeiRow = await (database.select(database.imeiItems)
          ..where((t) => t.imei1.equals(imei1)))
        .getSingleOrNull();
    if (imeiRow == null) return history;
    history.add(ImeiHistoryEntry(
      date: imeiRow.createdAt,
      event: 'purchased',
      detail: 'Added to stock at Rs ${imeiRow.purchasePrice}',
    ));
    if (imeiRow.soldSaleId != null) {
      final sale = await (database.select(database.sales)
            ..where((t) => t.id.equals(imeiRow.soldSaleId!)))
          .getSingleOrNull();
      if (sale != null) {
        history.add(ImeiHistoryEntry(
          date: sale.saleDate,
          event: 'sold',
          detail:
              'Sold on ${sale.invoiceNo} for Rs ${imeiRow.salePrice}',
          saleId: sale.id,
        ));
      }
    }
    final returns = await database.customSelect(
      'SELECT sr.created_at AS created_at, sr.reason AS reason, '
      'sr.refund_amount AS refund FROM sale_returns sr '
      'JOIN imei_items i ON i.id = sr.imei_item_id WHERE i.imei1 = ? '
      'ORDER BY sr.created_at ASC',
      variables: [Variable.withString(imei1)],
    ).get();
    for (final row in returns) {
      history.add(ImeiHistoryEntry(
        date: row.read<DateTime>('created_at'),
        event: 'returned',
        detail:
            'Returned (refund Rs ${row.read<int>('refund')})'
            '${row.readNullable<String>('reason') == null ? '' : ' — ${row.read<String>('reason')}'}',
      ));
    }
    history.sort((a, b) => a.date.compareTo(b.date));
    return history;
  }
}
