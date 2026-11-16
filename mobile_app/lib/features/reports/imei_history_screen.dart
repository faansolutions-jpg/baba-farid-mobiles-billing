library;

/// IMEI history lookup (route `/reports/imei`): enter a 15-digit IMEI
/// and see its full life — purchase, sale, returns — from
/// [ReportRepository.imeiHistory] plus the live IMEI item record.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/report_repository.dart';
import '../../domain/models/imei_item.dart';
import '../../core/providers/app_providers.dart';
import '../dashboard/shop_helpers.dart';

class ImeiHistoryScreen extends ConsumerStatefulWidget {
  const ImeiHistoryScreen({super.key, this.initialImei});

  /// Pre-filled IMEI (e.g. from the command palette `find imei ...`).
  final String? initialImei;

  @override
  ConsumerState<ImeiHistoryScreen> createState() => _ImeiHistoryScreenState();
}

class _ImeiHistoryScreenState extends ConsumerState<ImeiHistoryScreen> {
  final _controller = TextEditingController();
  List<ImeiHistoryEntry> _history = const [];
  ImeiItem? _item;
  String? _error;
  String? _notFound;
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImei != null && widget.initialImei!.isNotEmpty) {
      _controller.text = widget.initialImei!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final imei = _controller.text.trim();
    if (imei.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _notFound = null;
    });
    try {
      final reports = ref.read(reportRepositoryProvider);
      final products = ref.read(productRepositoryProvider);
      final history = await reports.imeiHistory(imei);
      final item = await products.getImeiByNumber(imei);
      if (!mounted) return;
      setState(() {
        _history = history;
        _item = item;
        _searched = true;
        _loading = false;
        if (history.isEmpty && item == null) {
          _notFound = imei;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _searched = true;
      });
    }
  }

  IconData _iconFor(String event) {
    return switch (event) {
      'purchased' => Icons.inventory_2,
      'sold' => Icons.point_of_sale,
      'returned' => Icons.undo,
      _ => Icons.history,
    };
  }

  String _labelFor(String event, String Function(String) t) {
    return switch (event) {
      'purchased' => t('purchasedEvent'),
      'sold' => t('soldEvent'),
      'returned' => t('returnedEvent'),
      _ => event,
    };
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final c = ref.watch(themeNotifierProvider).colors;

    return Scaffold(
      appBar: CyberAppBar(title: t('imeiHistory')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t('enterImei'), style: CyberTextStyles.bodySecondary(c)),
          const SizedBox(height: 12),
          CyberTextField(
            controller: _controller,
            label: t('imei'),
            hint: t('imeiHint'),
            monospace: true,
            keyboardType: TextInputType.number,
            maxLength: 15,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: t('imeiSearch'),
            icon: Icons.search,
            isLoading: _loading,
            onPressed: _loading ? null : _search,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            CyberCard(
              borderColor: c.error,
              child: Text(_error!, style: CyberTextStyles.body(c)),
            )
          else if (_notFound != null)
            CyberCard(
              borderColor: c.warning,
              child: Text(
                '${t('imeiNotFound')} ($_notFound)',
                style: CyberTextStyles.body(c),
              ),
            )
          else if (_searched) ...[
            if (_item != null) _itemCard(_item!, t, c),
            if (_history.isEmpty)
              CyberCard(
                child: Text(t('noHistory'),
                    style: CyberTextStyles.bodySecondary(c)),
              )
            else
              ..._history.map((e) => _historyTile(e, t, c)),
          ],
        ],
      ),
    );
  }

  Widget _itemCard(ImeiItem item, String Function(String) t, CyberColors c) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.imei1, style: CyberTextStyles.imei(c, size: 16)),
          const SizedBox(height: 8),
          _kv(t('repairStatus'), item.status, c),
          _kv(t('salePrice'), formatPkr(item.salePrice), c),
          _kv(t('costPrice'), formatPkr(item.purchasePrice), c),
          if (item.soldSaleId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CyberButton(
                label: '${t('newBill')} • ${item.soldSaleId!.substring(0, item.soldSaleId!.length > 8 ? 8 : item.soldSaleId!.length)}',
                variant: CyberButtonVariant.ghost,
                onPressed: () =>
                    context.push('/invoice/${item.soldSaleId}'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value, CyberColors c) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CyberTextStyles.bodySecondary(c)),
          Text(value, style: CyberTextStyles.mono(c, size: 14)),
        ],
      ),
    );
  }

  Widget _historyTile(
    ImeiHistoryEntry entry,
    String Function(String) t,
    CyberColors c,
  ) {
    return CyberCard(
      onTap: entry.saleId == null
          ? null
          : () => context.push('/invoice/${entry.saleId}'),
      child: Row(
        children: [
          Icon(_iconFor(entry.event), color: c.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelFor(entry.event, t),
                  style: CyberTextStyles.subtitle(c, size: 15),
                ),
                const SizedBox(height: 2),
                Text(entry.detail, style: CyberTextStyles.bodySecondary(c)),
              ],
            ),
          ),
          Text(
            formatShortDate(entry.date),
            style: CyberTextStyles.mono(c, size: 12),
          ),
        ],
      ),
    );
  }
}
