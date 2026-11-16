/// Repair job card — route `/repairs/:id`.
///
/// Full job card, status stepper (Received -> In Progress -> Ready ->
/// Delivered) via [RepairRepository.updateStatus], parts used (picked
/// from the catalog at their *sale* price — the price charged to the
/// customer — or entered manually), labour / other charges, payments
/// (advance + final), and a WhatsApp "repair ready" button.
///
/// Money rules (documented decisions):
/// * The final cost starts at the estimated cost. Adding a part records
///   the part (and deducts catalog stock when it comes from a variant)
///   but does NOT change the final cost by itself — the estimate may
///   already include parts. Use "Add Labour Charge" / "Update Final
///   Cost" to change what the customer pays; the parts total is shown
///   separately so the shopkeeper can compare.
/// * "Mark Delivered" is blocked while a balance is owed unless the
///   shopkeeper confirms delivery with the balance as udhaar. The
///   confirmed choice calls [RepairRepository.deliverWithUdhaar],
///   which delivers the job and posts the unpaid balance as an
///   udhaar debit to the customer ledger (when the job has a known
///   customer); the remaining balance stays visible on the
///   delivered job card.
/// * No purchase cost / profit is shown anywhere on this screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/repair_repository.dart';
import '../../domain/models/repair.dart';
import '../../domain/money.dart';
import '../../features/auth/auth_state.dart';
import '../../features/catalog/catalog_models.dart';
import '../../features/catalog/catalog_repository.dart';
import 'repair_common.dart';

const List<String> _steps = <String>[
  'received',
  'in_progress',
  'ready',
  'delivered',
];

const List<String> _paymentMethods = <String>[
  'cash',
  'jazzcash',
  'easypaisa',
  'bank',
  'card',
];

class RepairDetailScreen extends ConsumerStatefulWidget {
  const RepairDetailScreen({
    super.key,
    required this.repairId,
    required this.repository,
    this.catalogRepository,
    this.customerRepository,
  });

  final String repairId;
  final RepairRepository repository;

  /// When null, parts can only be entered manually.
  final CatalogRepository? catalogRepository;

  final CustomerRepository? customerRepository;

  @override
  ConsumerState<RepairDetailScreen> createState() =>
      _RepairDetailScreenState();
}

class _RepairDetailScreenState extends ConsumerState<RepairDetailScreen> {
  Repair? _repair;
  bool _loading = true;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _userId() => ref.read(authStateProvider).user?.id ?? 'local-user';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repair = await widget.repository.getRepair(widget.repairId);
      if (!mounted) return;
      setState(() {
        _repair = repair;
        _loading = false;
        if (repair == null) _error = 'Repair not found';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _mutate(
    Future<Repair> Function() call,
    String successKey,
    String Function(String) tr,
  ) async {
    setState(() => _busy = true);
    try {
      final updated = await call();
      if (!mounted) return;
      setState(() {
        _repair = updated;
        _busy = false;
      });
      showSnack(context, tr(successKey));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, e.toString(), isError: true);
    }
  }

  String _statusLabel(String status, String Function(String) tr) {
    switch (status) {
      case 'received':
        return tr('received');
      case 'in_progress':
        return tr('inProgress');
      case 'ready':
        return tr('ready');
      case 'delivered':
        return tr('delivered');
      case 'cancelled':
        return tr('cancelled');
      default:
        return status;
    }
  }

  String _methodLabel(String method, String Function(String) tr) {
    switch (method) {
      case 'cash':
        return tr('cash');
      case 'jazzcash':
        return tr('jazzCash');
      case 'easypaisa':
        return tr('easypaisa');
      case 'bank':
        return tr('bank');
      case 'card':
        return tr('card');
      default:
        return method;
    }
  }

  // -- Status ---------------------------------------------------------------

  Future<void> _changeStatus(
    String next,
    String Function(String) tr,
  ) async {
    final repair = _repair;
    if (repair == null) return;
    if (next == 'delivered' && repair.balanceDue > 0) {
      await _deliverWithBalance(tr);
      return;
    }
    await _mutate(
      () => widget.repository.updateStatus(
        repair.id,
        next,
        userId: _userId(),
      ),
      'statusUpdated',
      tr,
    );
  }

  /// Delivered with an unpaid balance: confirm udhaar, or record a
  /// payment first instead.
  Future<void> _deliverWithBalance(String Function(String) tr) async {
    final repair = _repair;
    if (repair == null) return;
    final dialogColors = ref.watch(themeNotifierProvider).colors;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => CyberDialog(
        title: tr('markDelivered'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(tr('cancel')),
          ),
          CyberButton(
            label: tr('recordPayment'),
            variant: CyberButtonVariant.ghost,
            fullWidth: false,
            onPressed: () => Navigator.of(context).pop('pay'),
          ),
          CyberButton(
            label: tr('deliverWithUdhaar'),
            variant: CyberButtonVariant.danger,
            fullWidth: false,
            onPressed: () => Navigator.of(context).pop('udhaar'),
          ),
        ],
        child: Text(
          '${tr('udhaarDeliverWarning')}\n\n'
          '${tr('balance')}: ${formatPkr(repair.balanceDue)}',
          style: CyberTextStyles.body(dialogColors),
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'pay') {
      await _recordPaymentDialog(tr);
    } else if (choice == 'udhaar') {
      setState(() => _busy = true);
      try {
        final updated = await widget.repository.deliverWithUdhaar(
          repair.id,
          userId: _userId(),
        );
        if (!mounted) return;
        setState(() {
          _repair = updated;
          _busy = false;
        });
        showSnack(
          context,
          '${tr('delivered')} — ${tr('udhaar')}: '
          '${formatPkr(repair.balanceDue)}',
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _busy = false);
        showSnack(context, e.toString(), isError: true);
      }
    }
  }

  Future<void> _cancelJob(String Function(String) tr) async {
    final repair = _repair;
    if (repair == null) return;
    final confirmed = await showCyberDialog(
      context,
      title: tr('cancelJob'),
      message: repair.jobNo,
      confirmLabel: tr('confirm'),
      cancelLabel: tr('cancel'),
      danger: true,
    );
    if (!confirmed) return;
    await _mutate(
      () => widget.repository.updateStatus(
        repair.id,
        'cancelled',
        userId: _userId(),
      ),
      'statusUpdated',
      tr,
    );
  }

  // -- Payments ---------------------------------------------------------------

  Future<void> _recordPaymentDialog(String Function(String) tr) async {
    final repair = _repair;
    if (repair == null) return;
    final amountController = TextEditingController(
      text: repair.balanceDue > 0 ? repair.balanceDue.toString() : '',
    );
    String method = 'cash';
    final formKey = GlobalKey<FormState>();
    final dialogColors = ref.watch(themeNotifierProvider).colors;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = dialogColors;
        return StatefulBuilder(
          builder: (context, setDialogState) => CyberDialog(
            title: tr('recordPayment'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(tr('cancel')),
              ),
              CyberButton(
                label: tr('save'),
                fullWidth: false,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${tr('balance')}: ${formatPkr(repair.balanceDue)}',
                    style: CyberTextStyles.mono(c, size: 14),
                  ),
                  const SizedBox(height: 12),
                  CyberTextField(
                    controller: amountController,
                    label: tr('paymentAmount'),
                    keyboardType: TextInputType.number,
                    monospace: true,
                    autofocus: true,
                    validator: (v) {
                      final amount = parsePkr(v ?? '');
                      if (amount == null || amount <= 0) {
                        return tr('invalidAmount');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: method,
                    decoration: InputDecoration(labelText: tr('paymentMethod')),
                    items: _paymentMethods
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m,
                            child: Text(_methodLabel(m, tr)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => method = v);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    final amount = parsePkr(amountController.text) ?? 0;
    amountController.dispose();
    if (saved != true || amount <= 0) return;
    setState(() => _busy = true);
    try {
      await widget.repository.recordRepairPayment(
        repairId: repair.id,
        amount: amount,
        method: method,
        userId: _userId(),
      );
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, tr('paymentRecorded'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, e.toString(), isError: true);
    }
  }

  // -- Parts ------------------------------------------------------------------

  Future<void> _addPartDialog(String Function(String) tr) async {
    final repair = _repair;
    if (repair == null) return;
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final searchController = TextEditingController();
    List<CatalogItem> results = <CatalogItem>[];
    bool searching = false;
    CatalogItem? picked;
    final formKey = GlobalKey<FormState>();
    final dialogColors = ref.watch(themeNotifierProvider).colors;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = dialogColors;
        return StatefulBuilder(
          builder: (context, setDialogState) => CyberDialog(
            title: tr('addPart'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(tr('cancel')),
              ),
              CyberButton(
                label: tr('save'),
                fullWidth: false,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.catalogRepository != null) ...[
                    CyberTextField(
                      controller: searchController,
                      label: tr('searchCatalog'),
                      prefixIcon: Icons.search,
                      onChanged: (q) async {
                        if (q.trim().length < 2) {
                          setDialogState(() => results = <CatalogItem>[]);
                          return;
                        }
                        setDialogState(() => searching = true);
                        try {
                          final found = await widget.catalogRepository!
                              .search(q.trim());
                          if (context.mounted) {
                            setDialogState(() {
                              results = found.take(8).toList();
                              searching = false;
                            });
                          }
                        } catch (_) {
                          if (context.mounted) {
                            setDialogState(() => searching = false);
                          }
                        }
                      },
                    ),
                    if (searching) const LinearProgressIndicator(),
                    ...results.map(
                      (item) => ListTile(
                        dense: true,
                        title: Text(item.nameEn),
                        subtitle: Text(
                          '${item.brand} · ${formatPkr(item.salePriceEst)}',
                          style: CyberTextStyles.mono(c, size: 12),
                        ),
                        selected: picked?.sku == item.sku,
                        onTap: () => setDialogState(() {
                          picked = item;
                          nameController.text = item.nameEn;
                          priceController.text =
                              item.salePriceEst.toString();
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  CyberTextField(
                    controller: nameController,
                    label: tr('partName'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? tr('fieldRequired') : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CyberTextField(
                          controller: qtyController,
                          label: tr('quantity'),
                          keyboardType: TextInputType.number,
                          monospace: true,
                          validator: (v) {
                            final qty = int.tryParse((v ?? '').trim());
                            if (qty == null || qty <= 0) {
                              return tr('invalidAmount');
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CyberTextField(
                          controller: priceController,
                          label: tr('unitPrice'),
                          keyboardType: TextInputType.number,
                          monospace: true,
                          validator: (v) {
                            final price = parsePkr(v ?? '');
                            if (price == null || price < 0) {
                              return tr('invalidAmount');
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    final name = nameController.text.trim();
    final qty = int.tryParse(qtyController.text.trim()) ?? 0;
    final price = parsePkr(priceController.text) ?? 0;
    final productId = picked?.sku;
    nameController.dispose();
    priceController.dispose();
    qtyController.dispose();
    searchController.dispose();
    if (saved != true || name.isEmpty || qty <= 0) return;
    setState(() => _busy = true);
    try {
      await widget.repository.addPart(
        RepairPart(
          id: '',
          repairId: repair.id,
          productId: productId,
          name: name,
          quantity: qty,
          unitPrice: price,
          total: price * qty,
          createdAt: DateTime.now(),
        ),
        userId: _userId(),
      );
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, tr('partAdded'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, e.toString(), isError: true);
    }
  }

  Future<void> _removePart(RepairPart part, String Function(String) tr) async {
    final confirmed = await showCyberDialog(
      context,
      title: tr('delete'),
      message: part.name,
      confirmLabel: tr('delete'),
      cancelLabel: tr('cancel'),
      danger: true,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await widget.repository.removePart(part.id, userId: _userId());
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, tr('deleted'));
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, e.toString(), isError: true);
    }
  }

  // -- Charges / final cost ---------------------------------------------------

  Future<void> _addLabourDialog(String Function(String) tr) async {
    final repair = _repair;
    if (repair == null) return;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => CyberDialog(
        title: tr('addLabour'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('cancel')),
          ),
          CyberButton(
            label: tr('save'),
            fullWidth: false,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CyberTextField(
                controller: amountController,
                label: tr('chargeAmount'),
                keyboardType: TextInputType.number,
                monospace: true,
                autofocus: true,
                validator: (v) {
                  final amount = parsePkr(v ?? '');
                  if (amount == null || amount <= 0) {
                    return tr('invalidAmount');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CyberTextField(
                controller: noteController,
                label: tr('chargeNote'),
              ),
            ],
          ),
        ),
      ),
    );
    final amount = parsePkr(amountController.text) ?? 0;
    final note = noteController.text.trim();
    amountController.dispose();
    noteController.dispose();
    if (saved != true || amount <= 0) return;
    final label = note.isEmpty ? tr('labourCharge') : note;
    final notes = repair.notes == null || repair.notes!.isEmpty
        ? '$label: ${formatPkr(amount)}'
        : '${repair.notes}\n$label: ${formatPkr(amount)}';
    await _mutate(
      () => widget.repository.updateRepair(
        repair.copyWith(
          finalCost: repair.finalCost + amount,
          notes: notes,
        ),
        userId: _userId(),
      ),
      'saved',
      tr,
    );
  }

  Future<void> _setFinalCostDialog(String Function(String) tr) async {
    final repair = _repair;
    if (repair == null) return;
    final controller =
        TextEditingController(text: repair.finalCost.toString());
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => CyberDialog(
        title: tr('setFinalCost'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('cancel')),
          ),
          CyberButton(
            label: tr('save'),
            fullWidth: false,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
        child: Form(
          key: formKey,
          child: CyberTextField(
            controller: controller,
            label: tr('finalCost'),
            keyboardType: TextInputType.number,
            monospace: true,
            autofocus: true,
            validator: (v) {
              final amount = parsePkr(v ?? '');
              if (amount == null || amount < 0) return tr('invalidAmount');
              if (amount < repair.advancePaid) return tr('invalidAmount');
              return null;
            },
          ),
        ),
      ),
    );
    final amount = parsePkr(controller.text) ?? -1;
    controller.dispose();
    if (saved != true || amount < 0) return;
    await _mutate(
      () => widget.repository.updateRepair(
        repair.copyWith(finalCost: amount),
        userId: _userId(),
      ),
      'saved',
      tr,
    );
  }

  // -- WhatsApp ---------------------------------------------------------------

  Future<void> _whatsappReady(String Function(String) tr) async {
    final repair = _repair;
    if (repair == null) return;
    final device = [
      if ((repair.deviceBrand ?? '').isNotEmpty) repair.deviceBrand!,
      if ((repair.deviceModel ?? '').isNotEmpty) repair.deviceModel!,
    ].join(' ');
    final message = repairReadyMessage(
      shopName: tr('appName'),
      jobNo: repair.jobNo,
      device: device,
      balanceDue: repair.balanceDue,
      readyLabel: tr('ready'),
      balanceLabel: tr('balance'),
    );
    final ok = await openWhatsApp(phone: repair.customerPhone, message: message);
    if (!mounted) return;
    if (!ok) showSnack(context, tr('whatsappNotAvailable'), isError: true);
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeNotifierProvider).colors;
    final lang = ref.watch(languageProvider);
    String tr(String key) => AppStrings.tr(key, language: lang);
    final repair = _repair;

    return Scaffold(
      appBar: CyberAppBar(title: tr('jobCard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || repair == null
              ? _errorView(c, tr)
              : _body(c, tr, repair),
    );
  }

  Widget _errorView(CyberColors c, String Function(String) tr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? tr('somethingWentWrong'),
              style: CyberTextStyles.error(c),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CyberButton(
              label: tr('tryAgain'),
              onPressed: _load,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(CyberColors c, String Function(String) tr, Repair repair) {
    final device = [
      if ((repair.deviceBrand ?? '').isNotEmpty) repair.deviceBrand!,
      if ((repair.deviceModel ?? '').isNotEmpty) repair.deviceModel!,
    ].join(' ');
    final stepIndex = _steps.indexOf(repair.status);
    final isClosed = repair.status == 'delivered' ||
        repair.status == 'cancelled';
    final nextStatus = repair.status == 'received'
        ? 'in_progress'
        : repair.status == 'in_progress'
            ? 'ready'
            : repair.status == 'ready'
                ? 'delivered'
                : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      repair.jobNo,
                      style: CyberTextStyles.mono(c, size: 18),
                    ),
                  ),
                  CyberBadge(
                    label: _statusLabel(repair.status, tr),
                    color: repair.status == 'delivered'
                        ? c.success
                        : repair.status == 'cancelled'
                            ? c.error
                            : repair.status == 'ready'
                                ? c.primary
                                : c.warning,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(repair.customerName,
                  style: CyberTextStyles.subtitle(c, size: 17)),
              Text(repair.customerPhone,
                  style: CyberTextStyles.mono(c, size: 14)),
              if (device.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(device, style: CyberTextStyles.body(c)),
              ],
              if ((repair.imei ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'IMEI: ${repair.imei}',
                  style: CyberTextStyles.imei(c, size: 13),
                ),
              ],
              const SizedBox(height: 8),
              Text(repair.faultDescription,
                  style: CyberTextStyles.bodySecondary(c)),
              if ((repair.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(repair.notes!, style: CyberTextStyles.body(c, size: 14)),
              ],
              const SizedBox(height: 12),
              _kvRow(c, tr('receivedDate'), fmtDate(repair.receivedDate)),
              if (repair.readyDate != null)
                _kvRow(c, tr('readyDate'), fmtDate(repair.readyDate!)),
              if (repair.deliveredDate != null)
                _kvRow(c, tr('deliveredDate'), fmtDate(repair.deliveredDate!)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('repairStatus'),
                  style: CyberTextStyles.label(c, size: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < _steps.length; i++) ...[
                    _stepDot(c, i, stepIndex),
                    if (i < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < stepIndex
                              ? c.primary
                              : c.border,
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    Expanded(
                      child: Text(
                        _statusLabel(_steps[i], tr),
                        textAlign: TextAlign.center,
                        style: CyberTextStyles.caption(c, size: 11).copyWith(
                          color: i <= stepIndex
                              ? c.primary
                              : c.textSecondary,
                          fontWeight: i == stepIndex
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_busy) const LinearProgressIndicator(),
              if (nextStatus != null)
                CyberButton(
                  label: nextStatus == 'delivered'
                      ? tr('markDelivered')
                      : nextStatus == 'ready'
                          ? tr('markReady')
                          : _statusLabel(nextStatus, tr),
                  icon: Icons.arrow_forward,
                  isLoading: _busy,
                  onPressed: _busy ? null : () => _changeStatus(nextStatus, tr),
                ),
              if (!isClosed) ...[
                const SizedBox(height: 8),
                CyberButton(
                  label: tr('cancelJob'),
                  variant: CyberButtonVariant.danger,
                  isLoading: _busy,
                  onPressed: _busy ? null : () => _cancelJob(tr),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        CyberCard(
          child: Column(
            children: [
              _moneyRow(c, tr('estimatedCost'), repair.estimatedCost),
              _moneyRow(c, tr('partsTotal'), repair.partsTotal),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('finalCost'), style: CyberTextStyles.body(c)),
                  TextButton(
                    onPressed: isClosed || _busy
                        ? null
                        : () => _setFinalCostDialog(tr),
                    child: Text(tr('updateFinalCost')),
                  ),
                ],
              ),
              _moneyRow(c, tr('finalCost'), repair.finalCost, big: true),
              _moneyRow(c, tr('advance'), repair.advancePaid),
              _moneyRow(
                c,
                tr('balance'),
                repair.balanceDue,
                big: true,
                highlight: repair.balanceDue > 0,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      label: tr('recordPayment'),
                      icon: Icons.payments,
                      variant: CyberButtonVariant.ghost,
                      isLoading: _busy,
                      onPressed:
                          isClosed || _busy ? null : () => _recordPaymentDialog(tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CyberButton(
                      label: tr('addLabour'),
                      icon: Icons.add,
                      variant: CyberButtonVariant.ghost,
                      isLoading: _busy,
                      onPressed:
                          isClosed || _busy ? null : () => _addLabourDialog(tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(tr('partsUsed'),
                        style: CyberTextStyles.label(c, size: 13)),
                  ),
                  TextButton.icon(
                    onPressed:
                        isClosed || _busy ? null : () => _addPartDialog(tr),
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(tr('addPart')),
                  ),
                ],
              ),
              if (repair.parts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(tr('noData'),
                      style: CyberTextStyles.bodySecondary(c)),
                ),
              ...repair.parts.map(
                (part) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(part.name),
                  subtitle: Text(
                    '${part.quantity} × ${formatPkr(part.unitPrice)}',
                    style: CyberTextStyles.mono(c, size: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatPkr(part.total),
                        style: CyberTextStyles.mono(c, size: 14),
                      ),
                      if (!isClosed)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: c.error),
                          tooltip: tr('delete'),
                          onPressed: _busy ? null : () => _removePart(part, tr),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CyberButton(
          label: tr('whatsappReady'),
          icon: Icons.chat,
          isLoading: _busy,
          onPressed: repair.status == 'ready' || repair.status == 'delivered'
              ? () => _whatsappReady(tr)
              : null,
        ),
      ],
    );
  }

  Widget _kvRow(CyberColors c, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CyberTextStyles.bodySecondary(c)),
          Text(value, style: CyberTextStyles.mono(c, size: 13)),
        ],
      ),
    );
  }

  Widget _moneyRow(
    CyberColors c,
    String label,
    int amount, {
    bool big = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: big
                ? CyberTextStyles.subtitle(c, size: 15)
                : CyberTextStyles.body(c),
          ),
          Text(
            formatPkr(amount),
            style: CyberTextStyles.amount(c, size: big ? 18 : 15).copyWith(
              color: highlight ? c.warning : c.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(CyberColors c, int index, int currentIndex) {
    final done = index < currentIndex;
    final current = index == currentIndex;
    final color = done || current ? c.primary : c.border;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: current ? c.primary : c.surface,
        border: Border.all(color: color, width: 2),
      ),
      child: done
          ? Icon(Icons.check, size: 16, color: c.onPrimary)
          : Text(
              '${index + 1}',
              style: CyberTextStyles.mono(c, size: 12).copyWith(
                color: current ? c.onPrimary : c.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
