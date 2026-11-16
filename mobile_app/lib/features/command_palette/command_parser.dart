library;

/// Pure-Dart command parser for the terminal-style command palette.
/// No Flutter imports, so it is unit-testable on its own.
///
/// Supported commands (case-insensitive, extra spaces tolerated):
///   sell <query>            -> open POS with the query
///   find imei <imei>        -> open the IMEI history screen
///   ledger <name>           -> open Customers filtered by name
///   stock <query>           -> open Inventory filtered by query
///   report today            -> open Reports
///   expense <amount> <note> -> create an expense (amount = plain digits)
///   help                    -> list commands
enum CommandKind {
  sell,
  findImei,
  ledger,
  stock,
  reportToday,
  expense,
  help,
  empty,
  unknown,
}

class ParsedCommand {
  const ParsedCommand({
    required this.kind,
    this.query = '',
    this.amount,
    this.note = '',
    this.raw = '',
  });

  final CommandKind kind;
  final String query;
  final int? amount;
  final String note;
  final String raw;

  /// Route the app should navigate to for this command, or null when
  /// the command performs an action instead of navigating.
  String? get route {
    return switch (kind) {
      CommandKind.sell =>
        '/pos?search=${Uri.encodeComponent(query)}',
      CommandKind.findImei =>
        '/reports/imei?imei=${Uri.encodeComponent(query)}',
      CommandKind.ledger =>
        '/customers?search=${Uri.encodeComponent(query)}',
      CommandKind.stock =>
        '/inventory?search=${Uri.encodeComponent(query)}',
      CommandKind.reportToday => '/reports',
      CommandKind.expense ||
      CommandKind.help ||
      CommandKind.empty ||
      CommandKind.unknown => null,
    };
  }
}

class CommandParser {
  const CommandParser._();

  /// One-line usage text for every command, shown by `help`.
  static const List<String> commandList = <String>[
    'sell <query> — open POS with a product',
    'find imei <imei> — show IMEI history',
    'ledger <name> — open a customer ledger',
    'stock <query> — search inventory',
    'report today — open today’s report',
    'expense <amount> <note> — record an expense',
    'help — list all commands',
  ];

  /// Command names offered by autocomplete.
  static const List<String> commandNames = <String>[
    'sell',
    'find imei',
    'ledger',
    'stock',
    'report today',
    'expense',
    'help',
  ];

  /// Parses [input] tolerantly: trims, collapses runs of spaces,
  /// and matches case-insensitively. Plain digits only for amounts
  /// (Roman Urdu numerals are not required).
  static ParsedCommand parse(String input) {
    final raw = input;
    final collapsed = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (collapsed.isEmpty) {
      return const ParsedCommand(kind: CommandKind.empty);
    }
    final lower = collapsed.toLowerCase();
    final parts = collapsed.split(' ');

    if (lower == 'help') {
      return ParsedCommand(kind: CommandKind.help, raw: raw);
    }
    if (lower == 'report today' || lower == 'report') {
      return ParsedCommand(kind: CommandKind.reportToday, raw: raw);
    }
    if (lower.startsWith('find imei ')) {
      final imei = collapsed.substring('find imei '.length).trim();
      if (imei.isEmpty) {
        return ParsedCommand(kind: CommandKind.unknown, raw: raw);
      }
      return ParsedCommand(kind: CommandKind.findImei, query: imei, raw: raw);
    }
    if (lower.startsWith('sell ')) {
      final query = collapsed.substring('sell '.length).trim();
      return ParsedCommand(kind: CommandKind.sell, query: query, raw: raw);
    }
    if (lower.startsWith('ledger ')) {
      final query = collapsed.substring('ledger '.length).trim();
      return ParsedCommand(kind: CommandKind.ledger, query: query, raw: raw);
    }
    if (lower.startsWith('stock ')) {
      final query = collapsed.substring('stock '.length).trim();
      return ParsedCommand(kind: CommandKind.stock, query: query, raw: raw);
    }
    if (lower.startsWith('expense ')) {
      if (parts.length < 2) {
        return ParsedCommand(kind: CommandKind.unknown, raw: raw);
      }
      final amount = int.tryParse(parts[1]);
      if (amount == null || amount <= 0) {
        return ParsedCommand(kind: CommandKind.unknown, raw: raw);
      }
      final note = parts.length > 2 ? parts.sublist(2).join(' ') : '';
      return ParsedCommand(
        kind: CommandKind.expense,
        amount: amount,
        note: note,
        raw: raw,
      );
    }
    return ParsedCommand(kind: CommandKind.unknown, raw: raw);
  }

  /// Autocomplete suggestions for [input]: command names starting
  /// with it, then matching history entries (most recent first).
  static List<String> suggestions(String input, List<String> history) {
    final q = input.trim().toLowerCase();
    final matches = <String>[];
    for (final name in commandNames) {
      if (q.isEmpty || name.startsWith(q)) matches.add(name);
    }
    for (final entry in history) {
      if (q.isNotEmpty &&
          entry.toLowerCase().startsWith(q) &&
          !matches.contains(entry)) {
        matches.add(entry);
      }
    }
    return matches;
  }
}
