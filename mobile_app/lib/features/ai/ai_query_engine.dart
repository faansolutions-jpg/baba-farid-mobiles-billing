library;

/// LOCAL rule-based query engine for the AI assistant (DECISIONS.md
/// #20). Pure Dart — no network, no external AI API, works offline.
///
/// Parses English + Roman Urdu questions into structured queries
/// against the shop's own repositories. Every answer carries the real
/// number, a short explanation and the route to open for detail.
/// Unknown questions never get a made-up number: they get the list of
/// questions the engine can answer.
import '../dashboard/shop_helpers.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/report_repository.dart';

/// One answered question.
class AiAnswer {
  const AiAnswer({
    required this.title,
    required this.body,
    this.lines = const [],
    this.route,
    this.routeLabel,
    this.isUnknown = false,
  });

  /// Short headline (contains the number when there is one).
  final String title;

  /// One or two sentences explaining the number.
  final String body;

  /// Detail rows shown under the body (e.g. top debtors).
  final List<String> lines;

  /// Screen to open for the full detail, or null.
  final String? route;

  /// Label for the open-screen button.
  final String? routeLabel;

  /// True when the question was not understood.
  final bool isUnknown;
}

class AiQueryEngine {
  AiQueryEngine({
    required this.reports,
    required this.products,
    required this.customers,
    required this.expenses,
  });

  final ReportRepository reports;
  final ProductRepository products;
  final CustomerRepository customers;
  final ExpenseRepository expenses;

  static String _normalize(String input) =>
      input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  static bool _has(String q, List<String> words) =>
      words.any((w) => q.contains(w));

  Future<AiAnswer> answer(String question, {bool canSeeCosts = true}) async {
    final q = _normalize(question);
    if (q.isEmpty) return _capabilities();

    if (_has(q, ['salam', 'assalam', 'hello', 'hi ', 'hey'])) {
      return const AiAnswer(
        title: 'Assalam-o-Alaikum!',
        body:
            'Ask me about your shop — sales, profit, stock, udhaar, best sellers, unsold mobiles or overdue installments.',
        route: '/reports',
        routeLabel: 'Reports',
      );
    }
    if (_has(q, ['help', 'madad', 'kya kar sakte', 'what can you'])) {
      return _capabilities();
    }

    // Profit — hidden for cashiers, never shown to them.
    if (_has(q, ['profit', 'munafa', 'faida', 'nafa'])) {
      if (!canSeeCosts) {
        return const AiAnswer(
          title: 'Profit is hidden for cashiers.',
          body:
              'Only the owner and manager can see profit figures. Ask the owner for today’s profit.',
          route: '/reports',
          routeLabel: 'Reports',
        );
      }
      final now = DateTime.now();
      final pl = await reports.profitAndLoss(startOfDay(now), now);
      return AiAnswer(
        title: 'Today’s profit: ${formatPkr(pl.netProfit)}',
        body:
            'Revenue ${formatPkr(pl.revenue)} minus cost of goods ${formatPkr(pl.costOfGoods)} and expenses ${formatPkr(pl.expenses)} leaves a net profit of ${formatPkr(pl.netProfit)} today.',
        route: '/reports',
        routeLabel: 'Reports',
      );
    }

    // Today's sales.
    if (_has(q, ['sale', 'bikri', 'farokht', 'becha', 'sell'])) {
      final now = DateTime.now();
      final totals =
          await reports.dashboardTotals(from: startOfDay(now), to: now);
      return AiAnswer(
        title: 'Today’s sales: ${formatPkr(totals.totalRevenue)}',
        body:
            '${totals.salesCount} bills so far today, worth ${formatPkr(totals.totalRevenue)}.',
        route: '/reports',
        routeLabel: 'Reports',
      );
    }

    // Low stock.
    if (_has(q, ['low stock', 'kam stock', 'khatam', 'stock kam', 'reorder'])) {
      final low = await products.lowStockVariants();
      if (low.isEmpty) {
        return const AiAnswer(
          title: 'No low-stock items.',
          body: 'Every variant is above its low-stock threshold right now.',
          route: '/inventory',
          routeLabel: 'Inventory',
        );
      }
      return AiAnswer(
        title: '${low.length} item(s) low in stock',
        body:
            'These variants are at or below their low-stock threshold and need reordering.',
        lines: low
            .take(5)
            .map((v) => '${v.name} — ${v.quantity} left')
            .toList(),
        route: '/inventory',
        routeLabel: 'Inventory',
      );
    }

    // Pending udhaar + top debtors.
    if (_has(q, ['udhaar', 'udhar', 'baqaya', 'debt', 'credit'])) {
      final list = await reports.pendingUdhaar();
      final total = list.fold<int>(0, (sum, u) => sum + u.balance);
      return AiAnswer(
        title: 'Pending udhaar: ${formatPkr(total)}',
        body:
            '${list.length} customer(s) owe the shop a total of ${formatPkr(total)}.',
        lines: list
            .take(3)
            .map((u) => '${u.customerName} — ${formatPkr(u.balance)}')
            .toList(),
        route: '/customers',
        routeLabel: 'Customers',
      );
    }

    // Best sellers.
    if (_has(q, ['best seller', 'behtareen', 'zyada bik', 'top sell', 'most sold'])) {
      final best = await reports.bestSellers(limit: 5);
      if (best.isEmpty) {
        return const AiAnswer(
          title: 'No sales yet in this period.',
          body: 'Best sellers will appear here once bills are recorded.',
          route: '/reports',
          routeLabel: 'Reports',
        );
      }
      return AiAnswer(
        title: 'Best seller: ${best.first.productName}',
        body:
            '${best.first.quantity} sold for ${formatPkr(best.first.revenue)}. Here are the top sellers of the last 30 days.',
        lines: best
            .map((b) =>
                '${b.productName} ${b.variantName} — ${b.quantity} sold, ${formatPkr(b.revenue)}')
            .toList(),
        route: '/reports',
        routeLabel: 'Reports',
      );
    }

    // Unsold / dead stock (60+ days).
    if (_has(q, ['unsold', 'dead stock', 'nahi bik', '60 din', '60 days', 'ruka hua', 'purana stock'])) {
      final dead = await reports.deadStock(days: 60);
      if (dead.isEmpty) {
        return const AiAnswer(
          title: 'No mobiles unsold for 60+ days.',
          body: 'Everything in stock has moved within the last 60 days.',
          route: '/reports',
          routeLabel: 'Reports',
        );
      }
      return AiAnswer(
        title: '${dead.length} item(s) unsold for 60+ days',
        body:
            'These have had no sale in 60 days or more. Consider a discount or bundle offer.',
        lines: dead
            .take(5)
            .map((d) =>
                '${d.productName} ${d.variantName} — ${d.daysUnsold} days${d.imei1 == null ? '' : ' • ${d.imei1}'}')
            .toList(),
        route: '/reports',
        routeLabel: 'Reports',
      );
    }

    // Stock valuation.
    if (_has(q, ['stock value', 'stock maliyat', 'stock kitna', 'stock ki value', 'valuation'])) {
      final v = await reports.stockValuation();
      return AiAnswer(
        title: 'Stock value: ${formatPkr(v.totalCostValue)} (cost)',
        body:
            '${v.phoneCount} phones worth ${formatPkr(v.phoneCostValue)} at cost and ${v.accessoryUnits} accessory units worth ${formatPkr(v.accessoryCostValue)}. Sale value is ${formatPkr(v.totalSaleValue)}.',
        route: '/reports',
        routeLabel: 'Reports',
      );
    }

    // Overdue installments.
    if (_has(q, ['installment', 'qist', 'overdue', 'kist'])) {
      final overdue = await customers.overdueInstallments();
      if (overdue.isEmpty) {
        return const AiAnswer(
          title: 'No overdue installments.',
          body: 'Every installment is paid or still within its due date.',
          route: '/customers',
          routeLabel: 'Customers',
        );
      }
      final lines = <String>[];
      for (final p in overdue.take(5)) {
        final inst = await customers.getInstallment(p.installmentId);
        final name = inst == null
            ? ''
            : (await customers.getCustomer(inst.customerId))?.name ?? '';
        lines.add(
          '${name.isEmpty ? 'Customer' : name} — ${formatPkr(p.amount - p.paidAmount)} due ${p.dueDate.day}/${p.dueDate.month}/${p.dueDate.year}',
        );
      }
      return AiAnswer(
        title: '${overdue.length} overdue installment(s)',
        body: 'These installments are past their due date. Send a reminder or collect the payment.',
        lines: lines,
        route: '/customers',
        routeLabel: 'Customers',
      );
    }

    // Cash in drawer.
    if (_has(q, ['cash', 'drawer', 'tijori', 'nagad'])) {
      final summary = await expenses.daySummary(date: DateTime.now());
      return AiAnswer(
        title: 'Expected cash: ${formatPkr(summary.expectedCash)}',
        body:
            'Opening ${formatPkr(summary.openingCash)}, cash in ${formatPkr(summary.cashIn)}, cash out ${formatPkr(summary.cashOut)}, expenses ${formatPkr(summary.totalExpenses)} today.',
        route: '/expenses',
        routeLabel: 'Expenses',
      );
    }

    return _capabilities(unknown: true);
  }

  AiAnswer _capabilities({bool unknown = false}) {
    return AiAnswer(
      title: unknown
          ? 'I do not know that yet.'
          : 'Here is what I can answer:',
      body: unknown
          ? 'I can only answer from your shop data — try one of the suggestions below. I never guess a number.'
          : 'I answer from your real shop data — sales, profit, stock, udhaar, best sellers, unsold mobiles, overdue installments and cash.',
      lines: const [
        'What is today’s profit?',
        'What is low in stock?',
        'How much udhaar is pending?',
        'Which mobiles are unsold for 60 days?',
      ],
      route: '/reports',
      routeLabel: 'Reports',
      isUnknown: unknown,
    );
  }
}
