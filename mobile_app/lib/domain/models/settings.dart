/// Settings model — the app-level aggregate view of the `settings`
/// key/value table in schema.sql (one row per key, e.g. `shop.name`,
/// `tax.rate`) plus the local-only device preferences stored in
/// shared_preferences (theme, language, animations, printer).
///
/// The repository converts between this aggregate and the key/value rows
/// via [toKeyValues] / [Settings.fromKeyValues].
library;

/// Printer paper width.
class PrinterWidth {
  static const mm58 = '58mm';
  static const mm80 = '80mm';
}

class Settings {
  // Shop profile (settings keys shop.*).
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String shopPhone2;
  final String shopEmail;
  final String currency;

  // Tax (keys tax.enabled, tax.rate).
  final bool taxEnabled;
  final double taxRate;

  // Printer (keys printer.*).
  final String printerName;
  final String printerWidth;
  final bool printReceiptByDefault;

  // App / device preferences (shared_preferences keys, same names).
  final String theme; // hacker | matrix | cyberBlue | light
  final String language; // en | ur
  final bool animationsEnabled;
  final bool privacyMode;
  final int autoLockMinutes;

  // Invoice counter prefix is stored in `counters`, not here.
  const Settings({
    this.shopName = 'Baba Farid Mobiles',
    this.shopAddress = 'Jamal Chowk, Depalpur Road, Pakpattan',
    this.shopPhone = '+92 329 9966771',
    this.shopPhone2 = '+92 302 4988560',
    this.shopEmail = 'baba.farid.mobiles.bfw@gmail.com',
    this.currency = 'PKR',
    this.taxEnabled = false,
    this.taxRate = 0,
    this.printerName = '',
    this.printerWidth = PrinterWidth.mm80,
    this.printReceiptByDefault = true,
    this.theme = 'hacker',
    this.language = 'en',
    this.animationsEnabled = true,
    this.privacyMode = false,
    this.autoLockMinutes = 2,
  });

  /// Builds a [Settings] from raw settings-table rows
  /// (`{key: value}` where value is the decoded JSON value).
  factory Settings.fromKeyValues(Map<String, dynamic> values) {
    dynamic v(String key, [dynamic fallback]) =>
        values.containsKey(key) ? values[key] : fallback;
    return Settings(
      shopName: v('shop.name', 'Baba Farid Mobiles') as String,
      shopAddress:
          v('shop.address', 'Jamal Chowk, Depalpur Road, Pakpattan') as String,
      shopPhone: v('shop.phone', '+92 329 9966771') as String,
      shopPhone2: v('shop.phone2', '+92 302 4988560') as String,
      shopEmail: v('shop.email', 'baba.farid.mobiles.bfw@gmail.com') as String,
      currency: v('shop.currency', 'PKR') as String,
      taxEnabled: v('tax.enabled', false) as bool,
      taxRate: (v('tax.rate', 0) as num).toDouble(),
      printerName: v('printer.name', '') as String,
      printerWidth: v('printer.width', PrinterWidth.mm80) as String,
      printReceiptByDefault: v('printer.auto_print', true) as bool,
      theme: v('app.theme', 'hacker') as String,
      language: v('app.language', 'en') as String,
      animationsEnabled: v('app.animations', true) as bool,
      privacyMode: v('app.privacy_mode', false) as bool,
      autoLockMinutes: (v('app.auto_lock_minutes', 2) as num).toInt(),
    );
  }

  /// Flattens this aggregate into settings-table key/value rows.
  Map<String, dynamic> toKeyValues() => {
        'shop.name': shopName,
        'shop.address': shopAddress,
        'shop.phone': shopPhone,
        'shop.phone2': shopPhone2,
        'shop.email': shopEmail,
        'shop.currency': currency,
        'tax.enabled': taxEnabled,
        'tax.rate': taxRate,
        'printer.name': printerName,
        'printer.width': printerWidth,
        'printer.auto_print': printReceiptByDefault,
        'app.theme': theme,
        'app.language': language,
        'app.animations': animationsEnabled,
        'app.privacy_mode': privacyMode,
        'app.auto_lock_minutes': autoLockMinutes,
      };

  Map<String, dynamic> toJson() => toKeyValues();

  factory Settings.fromJson(Map<String, dynamic> json) =>
      Settings.fromKeyValues(json);

  Settings copyWith({
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopPhone2,
    String? shopEmail,
    String? currency,
    bool? taxEnabled,
    double? taxRate,
    String? printerName,
    String? printerWidth,
    bool? printReceiptByDefault,
    String? theme,
    String? language,
    bool? animationsEnabled,
    bool? privacyMode,
    int? autoLockMinutes,
  }) =>
      Settings(
        shopName: shopName ?? this.shopName,
        shopAddress: shopAddress ?? this.shopAddress,
        shopPhone: shopPhone ?? this.shopPhone,
        shopPhone2: shopPhone2 ?? this.shopPhone2,
        shopEmail: shopEmail ?? this.shopEmail,
        currency: currency ?? this.currency,
        taxEnabled: taxEnabled ?? this.taxEnabled,
        taxRate: taxRate ?? this.taxRate,
        printerName: printerName ?? this.printerName,
        printerWidth: printerWidth ?? this.printerWidth,
        printReceiptByDefault:
            printReceiptByDefault ?? this.printReceiptByDefault,
        theme: theme ?? this.theme,
        language: language ?? this.language,
        animationsEnabled: animationsEnabled ?? this.animationsEnabled,
        privacyMode: privacyMode ?? this.privacyMode,
        autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          other.shopName == shopName &&
          other.shopAddress == shopAddress &&
          other.shopPhone == shopPhone &&
          other.shopEmail == shopEmail &&
          other.taxEnabled == taxEnabled &&
          other.taxRate == taxRate &&
          other.theme == theme &&
          other.language == language &&
          other.animationsEnabled == animationsEnabled &&
          other.privacyMode == privacyMode;

  @override
  int get hashCode => Object.hash(shopName, shopAddress, shopPhone,
      shopEmail, taxEnabled, taxRate, theme, language, animationsEnabled,
      privacyMode);
}

/// One invoice-number counter (`counters` table), e.g. branch + name
/// `sale_invoice`, prefix `INV`, last value 123 -> next is `INV-000124`.
class Counter {
  final String? branchId;
  final String name;
  final String prefix;
  final int lastValue;

  const Counter({
    this.branchId,
    required this.name,
    required this.prefix,
    this.lastValue = 0,
  });

  factory Counter.fromJson(Map<String, dynamic> json) => Counter(
        branchId: json['branch_id'] as String?,
        name: json['name'] as String,
        prefix: json['prefix'] as String,
        lastValue: (json['last_value'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'branch_id': branchId,
        'name': name,
        'prefix': prefix,
        'last_value': lastValue,
      };

  Counter copyWith({
    String? branchId,
    String? name,
    String? prefix,
    int? lastValue,
  }) =>
      Counter(
        branchId: branchId ?? this.branchId,
        name: name ?? this.name,
        prefix: prefix ?? this.prefix,
        lastValue: lastValue ?? this.lastValue,
      );

  /// Formats the next document number, e.g. `INV-000124`.
  String nextNumber() =>
      '$prefix-${(lastValue + 1).toString().padLeft(6, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Counter &&
          other.branchId == branchId &&
          other.name == name &&
          other.lastValue == lastValue;

  @override
  int get hashCode => Object.hash(branchId, name, lastValue);
}
