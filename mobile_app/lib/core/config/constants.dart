/// Route names, payment methods, roles and shared app constants.
///
/// Route name strings ONLY — the actual route table / GoRouter wiring is
/// owned by Round 2 (see PLAN.md). Screens navigate with
/// `Navigator.pushNamed(context, AppRoutes.dashboard)` until then.
library;

/// Route paths used across the app. Round 2 registers these in the router;
/// until then, navigation to an unregistered route is guarded in the
/// login screen so the user sees a clear message instead of a crash.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String pos = '/pos';
  static const String inventory = '/inventory';
  static const String customers = '/customers';
  static const String purchases = '/purchases';
  static const String repairs = '/repairs';
  static const String expenses = '/expenses';
  static const String reports = '/reports';
  static const String settings = '/settings';

  /// Every route the app knows about, in navigation order.
  static const List<String> all = <String>[
    splash,
    login,
    dashboard,
    pos,
    inventory,
    customers,
    purchases,
    repairs,
    expenses,
    reports,
    settings,
  ];
}

/// Payment methods accepted at the counter (README.md Module B).
class PaymentMethods {
  const PaymentMethods._();

  static const String cash = 'Cash';
  static const String jazzCash = 'JazzCash';
  static const String easypaisa = 'Easypaisa';
  static const String bank = 'Bank';
  static const String card = 'Card';
  static const String partial = 'Partial';
  static const String udhaar = 'Udhaar';

  static const List<String> all = <String>[
    cash,
    jazzCash,
    easypaisa,
    bank,
    card,
    partial,
    udhaar,
  ];

  /// Methods that leave a balance owing on the customer ledger.
  static const List<String> creditMethods = <String>[partial, udhaar];

  /// Methods settled in full at the counter.
  static const List<String> fullPaymentMethods = <String>[
    cash,
    jazzCash,
    easypaisa,
    bank,
    card,
  ];
}

/// User roles (README.md §2 / DECISIONS.md #6).
class UserRoles {
  const UserRoles._();

  static const String owner = 'owner';
  static const String manager = 'manager';
  static const String cashier = 'cashier';

  static const List<String> all = <String>[owner, manager, cashier];

  /// Roles allowed to see purchase cost / profit figures.
  static const List<String> canSeeCosts = <String>[owner, manager];

  /// Roles allowed to approve a below-minimum-price sale.
  static const List<String> canApproveBelowMinPrice = <String>[owner];
}

/// Miscellaneous app-wide constants.
class AppConstants {
  const AppConstants._();

  /// Minimum touch-target size (dp) for every tappable control.
  static const double minTouchTarget = 48.0;

  /// Standard paddings / radii used by the cyber widgets.
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double cornerCut = 12.0;
  static const double borderRadius = 8.0;

  /// PIN length for the quick-login PIN.
  static const int pinLength = 4;

  /// TOTP code length for owner 2FA (DECISIONS.md #8).
  static const int totpLength = 6;

  /// IMEI length (15 digits).
  static const int imeiLength = 15;

  /// Default page size for lists.
  static const int pageSize = 50;

  /// Search debounce (ms) for the POS / inventory search bars.
  static const int searchDebounceMs = 200;

  /// Splash boot-sequence line delay (ms) when animations are on.
  static const int splashLineDelayMs = 450;

  /// Loyalty: 1 point per Rs 100 spent; 100 points = Rs 100 (DECISIONS.md #23).
  static const int loyaltyRupeesPerPoint = 100;
  static const int loyaltyPointsPerReward = 100;
  static const int loyaltyRewardRupees = 100;
}
