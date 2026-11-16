library;

/// Settings (route `/settings`): shop info, invoice template + tax,
/// printer, language, theme, animations, HUD animation level +
/// battery-saver auto-off, privacy mode, auto-lock timeout, and a link
/// to backup & restore (`/settings/backup`).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_colors.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';
import '../../domain/models/settings.dart';
import '../auth/auth_state.dart';
import '../../core/providers/app_providers.dart';
import '../hud/hud_performance.dart';
import '../hud/hud_settings.dart';
import '../hud/hud_theme.dart';

const String _invoiceTemplateKey = 'invoice_template';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Settings? _settings;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _phone2 = TextEditingController();
  final _email = TextEditingController();
  final _taxRate = TextEditingController();
  final _printerName = TextEditingController();
  final _target = TextEditingController();

  String _invoiceTemplate = 'Standard';
  String _printerWidth = PrinterWidth.mm80;
  HudAnimationLevel _hudLevel = HudAnimationLevel.full;
  bool _hudBatterySaver = true;
  bool _videoBackground = false;

  /// Manual sync state (the "Sync now" button below).
  bool _syncing = false;
  String? _syncMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _phone2.dispose();
    _email.dispose();
    _taxRate.dispose();
    _printerName.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(settingsRepositoryProvider);
      final settings = await repo.getSettings();
      final prefs = await SharedPreferences.getInstance();
      final hud = await HudSettings.load();
      if (!mounted) return;
      _name.text = settings.shopName;
      _address.text = settings.shopAddress;
      _phone.text = settings.shopPhone;
      _phone2.text = settings.shopPhone2;
      _email.text = settings.shopEmail;
      _taxRate.text = settings.taxRate.toString();
      _printerName.text = settings.printerName;
      _target.text =
          (prefs.getInt(dailySalesTargetKey) ?? defaultDailySalesTarget)
              .toString();
      setState(() {
        _settings = settings;
        _invoiceTemplate =
            prefs.getString(_invoiceTemplateKey) ?? 'Standard';
        _printerWidth = settings.printerWidth;
        _hudLevel = hud.level;
        _hudBatterySaver = hud.batterySaverAutoOff;
        _videoBackground = hud.videoBackground;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Manual "Sync now": pushes local sales/changes to the server and
  /// pulls the server's products, variants, customers and catalog into
  /// the local database. Shows a short result message; a failed sync
  /// never loses local data.
  Future<void> _syncNow() async {
    if (_syncing) return;
    setState(() {
      _syncing = true;
      _syncMessage = null;
    });
    try {
      final result = await ref.read(syncEngineProvider).sync();
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _syncMessage =
            '${AppStrings.tr('syncDone', language: ref.read(languageProvider))} '
            'Pushed ${result.pushed}, pulled ${result.pulled}.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _syncMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr('syncFailed',
              language: ref.read(languageProvider))),
        ),
      );
    }
  }

  Future<void> _saveShopInfo() async {
    final current = _settings;
    if (current == null) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(settingsRepositoryProvider);
      final updated = current.copyWith(
        shopName: _name.text.trim(),
        shopAddress: _address.text.trim(),
        shopPhone: _phone.text.trim(),
        shopPhone2: _phone2.text.trim(),
        shopEmail: _email.text.trim(),
        taxRate: double.tryParse(_taxRate.text.trim()) ?? current.taxRate,
        printerName: _printerName.text.trim(),
        printerWidth: _printerWidth,
      );
      await repo.saveSettings(updated);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_invoiceTemplateKey, _invoiceTemplate);
      final target = int.tryParse(_target.text.trim());
      if (target != null && target > 0) {
        await prefs.setInt(dailySalesTargetKey, target);
      }
      if (!mounted) return;
      setState(() {
        _settings = updated;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('saved'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_t('error')}: $e')),
      );
    }
  }

  String _t(String key) {
    final lang = ref.read(languageProvider);
    return AppStrings.tr(key, language: lang);
  }

  Future<void> _setTheme(CyberThemeMode mode) async {
    ref.read(themeNotifierProvider.notifier).setMode(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.themeKey, mode.storageValue);
    final current = _settings;
    if (current != null) {
      final updated = current.copyWith(theme: mode.storageValue);
      await ref.read(settingsRepositoryProvider).saveSettings(updated);
      if (mounted) setState(() => _settings = updated);
    }
  }

  Future<void> _setLanguage(String lang) async {
    ref.read(languageProvider.notifier).state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.languageKey, lang);
    final current = _settings;
    if (current != null) {
      final updated = current.copyWith(language: lang);
      await ref.read(settingsRepositoryProvider).saveSettings(updated);
      if (mounted) setState(() => _settings = updated);
    }
  }

  Future<void> _setAnimations(bool enabled) async {
    ref.read(themeNotifierProvider.notifier).setAnimationsEnabled(enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.animationsEnabledKey, enabled);
    final current = _settings;
    if (current != null) {
      final updated = current.copyWith(animationsEnabled: enabled);
      await ref.read(settingsRepositoryProvider).saveSettings(updated);
      if (mounted) setState(() => _settings = updated);
    }
  }

  Future<void> _setPrivacy(bool enabled) async {
    ref.read(privacyModeProvider.notifier).state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.privacyModeKey, enabled);
    final current = _settings;
    if (current != null) {
      final updated = current.copyWith(privacyMode: enabled);
      await ref.read(settingsRepositoryProvider).saveSettings(updated);
      if (mounted) setState(() => _settings = updated);
    }
  }

  Future<void> _setAutoLock(int minutes) async {
    final current = _settings;
    if (current == null) return;
    final updated = current.copyWith(autoLockMinutes: minutes);
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    if (mounted) setState(() => _settings = updated);
  }

  Future<void> _setHudLevel(HudAnimationLevel level) async {
    final hud = HudSettings.current.copyWith(level: level);
    await HudSettings.save(hud);
    HudPerformanceManager.instance.setLevel(level);
    if (mounted) setState(() => _hudLevel = level);
  }

  Future<void> _setHudBatterySaver(bool value) async {
    final hud = HudSettings.current.copyWith(batterySaverAutoOff: value);
    await HudSettings.save(hud);
    if (mounted) setState(() => _hudBatterySaver = value);
  }

  Future<void> _setVideoBackground(bool value) async {
    final hud = HudSettings.current.copyWith(videoBackground: value);
    await HudSettings.save(hud);
    if (mounted) setState(() => _videoBackground = value);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final theme = ref.watch(themeNotifierProvider);
    final c = theme.colors;
    final settings = _settings;

    return Scaffold(
      appBar: CyberAppBar(title: t('settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && settings == null
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    CyberCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('error'),
                              style: CyberTextStyles.title(c, size: 18)),
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: CyberTextStyles.bodySecondary(c)),
                          const SizedBox(height: 16),
                          CyberButton(
                            label: t('tryAgain'),
                            onPressed: _load,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _section(t('shopInfo'), c),
                    CyberTextField(
                      controller: _name,
                      label: t('shopName'),
                    ),
                    const SizedBox(height: 12),
                    CyberTextField(
                      controller: _address,
                      label: t('shopAddress'),
                    ),
                    const SizedBox(height: 12),
                    CyberTextField(
                      controller: _phone,
                      label: t('phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    CyberTextField(
                      controller: _phone2,
                      label: t('phone2'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    CyberTextField(
                      controller: _email,
                      label: t('email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _section(t('invoiceTemplate'), c),
                    _dropdown<String>(
                      value: _invoiceTemplate,
                      items: const ['Standard', 'Compact', 'Detailed'],
                      onChanged: (v) =>
                          setState(() => _invoiceTemplate = v ?? 'Standard'),
                      c: c,
                    ),
                    const SizedBox(height: 12),
                    CyberTextField(
                      controller: _target,
                      label: t('dailyTarget'),
                      keyboardType: TextInputType.number,
                      monospace: true,
                    ),
                    const SizedBox(height: 16),
                    _section(t('tax'), c),
                    CyberToggle(
                      label: t('taxEnabled'),
                      value: settings!.taxEnabled,
                      onChanged: (v) async {
                        final updated = settings.copyWith(taxEnabled: v);
                        await ref
                            .read(settingsRepositoryProvider)
                            .saveSettings(updated);
                        if (mounted) {
                          setState(() => _settings = updated);
                        }
                      },
                    ),
                    CyberTextField(
                      controller: _taxRate,
                      label: t('taxRate'),
                      keyboardType: TextInputType.number,
                      monospace: true,
                    ),
                    const SizedBox(height: 16),
                    _section(t('printer'), c),
                    CyberTextField(
                      controller: _printerName,
                      label: t('printerName'),
                    ),
                    const SizedBox(height: 12),
                    _dropdown<String>(
                      value: _printerWidth,
                      items: const [
                        PrinterWidth.mm58,
                        PrinterWidth.mm80,
                      ],
                      onChanged: (v) => setState(
                        () => _printerWidth = v ?? PrinterWidth.mm80,
                      ),
                      c: c,
                    ),
                    CyberToggle(
                      label: t('printReceiptDefault'),
                      value: settings.printReceiptByDefault,
                      onChanged: (v) async {
                        final updated =
                            settings.copyWith(printReceiptByDefault: v);
                        await ref
                            .read(settingsRepositoryProvider)
                            .saveSettings(updated);
                        if (mounted) {
                          setState(() => _settings = updated);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CyberButton(
                      label: t('save'),
                      icon: Icons.save,
                      isLoading: _saving,
                      onPressed: _saving ? null : _saveShopInfo,
                    ),
                    const SizedBox(height: 24),
                    _section(t('language'), c),
                    Row(
                      children: [
                        Expanded(
                          child: CyberChip(
                            label: t('english'),
                            selected: lang == 'en',
                            onSelected: (_) => _setLanguage('en'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CyberChip(
                            label: t('urdu'),
                            selected: lang == 'ur',
                            onSelected: (_) => _setLanguage('ur'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _section(t('theme'), c),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CyberColors.allModes
                          .map(
                            (mode) => CyberChip(
                              label: themeModeLabel(mode),
                              selected: theme.mode == mode,
                              onSelected: (_) => _setTheme(mode),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _section(t('animations'), c),
                    CyberToggle(
                      label: t('animations'),
                      value: theme.animationsEnabled,
                      onChanged: _setAnimations,
                    ),
                    _section(t('hudAnimation'), c),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: HudAnimationLevel.values
                          .map(
                            (level) => CyberChip(
                              label: switch (level) {
                                HudAnimationLevel.full => t('hudFull'),
                                HudAnimationLevel.reduced => t('hudReduced'),
                                HudAnimationLevel.off => t('hudOff'),
                              },
                              selected: _hudLevel == level,
                              onSelected: (_) => _setHudLevel(level),
                            ),
                          )
                          .toList(),
                    ),
                    CyberToggle(
                      label: t('batterySaverAutoOff'),
                      value: _hudBatterySaver,
                      onChanged: _setHudBatterySaver,
                    ),
                    CyberToggle(
                      label: t('videoBackground'),
                      value: _videoBackground,
                      onChanged: _setVideoBackground,
                    ),
                    const SizedBox(height: 16),
                    _section(t('privacyMode'), c),
                    CyberToggle(
                      label: t('privacyMode'),
                      value: ref.watch(privacyModeProvider),
                      onChanged: _setPrivacy,
                    ),
                    const SizedBox(height: 16),
                    _section(t('autoLock'), c),
                    _dropdown<int>(
                      value: settings.autoLockMinutes,
                      items: const [1, 2, 5, 10, 30],
                      labelBuilder: (m) => '$m ${t('autoLock')}',
                      onChanged: (v) {
                        if (v != null) _setAutoLock(v);
                      },
                      c: c,
                    ),
                    const SizedBox(height: 24),
                    _section(t('sync'), c),
                    CyberButton(
                      label: t('syncNow'),
                      icon: Icons.sync,
                      isLoading: _syncing,
                      onPressed: _syncing ? null : _syncNow,
                    ),
                    if (_syncMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _syncMessage!,
                        style: CyberTextStyles.bodySecondary(c),
                      ),
                    ],
                    const SizedBox(height: 24),
                    CyberButton(
                      label: t('backupRestore'),
                      icon: Icons.backup,
                      variant: CyberButtonVariant.ghost,
                      onPressed: () => context.push('/settings/backup'),
                    ),
                    const SizedBox(height: 8),
                    CyberButton(
                      label: t('logout'),
                      icon: Icons.logout,
                      variant: CyberButtonVariant.danger,
                      onPressed: () async {
                        // Capture the router before any async gap so no
                        // BuildContext is used after awaiting.
                        final router = GoRouter.of(context);
                        final confirmed = await showCyberDialog(
                          context,
                          title: t('logout'),
                          message: t('logout'),
                          confirmLabel: t('logout'),
                        );
                        if (!confirmed) return;
                        await ref
                            .read(authStateProvider.notifier)
                            .logout();
                        router.go('/login');
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '${AppConfig.appName} v${AppConfig.versionDisplay}',
                        style: CyberTextStyles.caption(c),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _section(String title, CyberColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: CyberTextStyles.title(c, size: 18)),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required CyberColors c,
    String Function(T)? labelBuilder,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: c.surface,
        style: CyberTextStyles.body(c, size: 15),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder == null ? item.toString() : labelBuilder(item),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
