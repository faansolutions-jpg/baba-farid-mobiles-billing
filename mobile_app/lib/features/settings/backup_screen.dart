library;

/// Backup & restore (route `/settings/backup`): exports the local
/// SQLite database file (`baba_farid_mobiles.db`) to a shareable file
/// and restores from a picked file (with a confirm dialog).
///
/// Google Drive upload is a documented MANUAL step (DECISIONS.md #25):
/// there are no Drive API credentials, so the screen offers an
/// "open Drive" helper that opens drive.google.com — it never pretends
/// to upload by itself.
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyber_text_styles.dart';
import '../../core/theme/cyber_widgets.dart';

const String _dbFileName = 'baba_farid_mobiles.db';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _status;

  String _t(String key) {
    final lang = ref.read(languageProvider);
    return AppStrings.tr(key, language: lang);
  }

  Future<File> _dbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_dbFileName');
  }

  Future<void> _exportBackup() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final db = await _dbFile();
      if (!await db.exists()) {
        throw Exception('Database file not found (${db.path}).');
      }
      final stamp =
          DateTime.now().toIso8601String().substring(0, 19).replaceAll(':', '-');
      final tmp = await getTemporaryDirectory();
      final copy = await db.copy('${tmp.path}/baba-farid-backup-$stamp.db');
      await Share.shareXFiles(
        [XFile(copy.path)],
        subject: 'Baba Farid Mobiles backup',
        text: 'Baba Farid Mobiles backup $stamp',
      );
      if (mounted) setState(() => _status = _t('backupExported'));
    } catch (e) {
      if (mounted) setState(() => _status = '${_t('error')}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importBackup() async {
    final confirmed = await showCyberDialog(
      context,
      title: _t('restoreConfirm'),
      message: _t('restoreConfirmMessage'),
      confirmLabel: _t('restore'),
      danger: true,
    );
    if (!confirmed) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      final path = result?.files.single.path;
      if (path == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final picked = File(path);
      final db = await _dbFile();
      await picked.copy(db.path);
      if (mounted) setState(() => _status = _t('backupImported'));
    } catch (e) {
      if (mounted) setState(() => _status = '${_t('error')}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openDrive() async {
    final uri = Uri.parse('https://drive.google.com');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    String t(String key) => AppStrings.tr(key, language: lang);
    final c = ref.watch(themeNotifierProvider).colors;

    return Scaffold(
      appBar: CyberAppBar(title: t('backupRestore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('backup'), style: CyberTextStyles.title(c, size: 18)),
                const SizedBox(height: 8),
                Text(
                  t('driveHelp'),
                  style: CyberTextStyles.bodySecondary(c),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CyberButton(
            label: t('exportBackup'),
            icon: Icons.upload,
            isLoading: _busy,
            onPressed: _busy ? null : _exportBackup,
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: t('importBackup'),
            icon: Icons.download,
            variant: CyberButtonVariant.ghost,
            isLoading: _busy,
            onPressed: _busy ? null : _importBackup,
          ),
          const SizedBox(height: 12),
          CyberButton(
            label: t('openDrive'),
            icon: Icons.cloud_upload,
            variant: CyberButtonVariant.ghost,
            onPressed: _openDrive,
          ),
          if (_status != null) ...[
            const SizedBox(height: 16),
            CyberCard(
              child: Text(_status!, style: CyberTextStyles.body(c)),
            ),
          ],
        ],
      ),
    );
  }
}
