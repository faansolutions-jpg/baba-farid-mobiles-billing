import 'package:flutter/material.dart';

import 'hud_core.dart';
import 'hud_count_up.dart';
import 'hud_gauges.dart';
import 'hud_panel.dart';
import 'hud_theme.dart';

/// Dashboard hero widget: the [HudCore] in the centre, flanked by
/// side panels built ONLY from the real values passed in as
/// constructor params. Round 2 wires these params to the repositories
/// (sales / stock / cash / ledger). All numbers use [HudCountUp].
///
/// Panels:
/// * CORE TEMP — today's sales vs target (0-1 gauge + amount).
/// * STOCK CHECK — stock health %.
/// * CASH DRAWER — cash amount.
/// * PENDING UDHAAR — amount + count.
/// * LOW STOCK ALERTS — count.
/// * SYNC STATUS — text + [isSynced] dot.
class HudDashboardHero extends StatelessWidget {
  const HudDashboardHero({
    super.key,
    required this.salesToday,
    required this.salesTarget,
    required this.stockHealth,
    required this.cashDrawer,
    required this.pendingUdhaarAmount,
    required this.pendingUdhaarCount,
    required this.lowStockAlerts,
    required this.syncStatus,
    required this.isSynced,
    this.isAnimating = true,
    this.particleBudget = 600,
    this.frameSkip = 1,
  });

  /// Today's sales in whole PKR.
  final int salesToday;

  /// Today's sales target in whole PKR.
  final int salesTarget;

  /// Stock health 0.0-1.0 (healthy stock / total stock).
  final double stockHealth;

  /// Cash in drawer in whole PKR.
  final int cashDrawer;

  /// Total pending udhaar in whole PKR.
  final int pendingUdhaarAmount;

  /// Number of customers with pending udhaar.
  final int pendingUdhaarCount;

  /// Number of low-stock alerts.
  final int lowStockAlerts;

  /// Sync status text, e.g. "SYNCED 10:24" or "3 PENDING".
  final String syncStatus;

  /// True when fully synced.
  final bool isSynced;

  final bool isAnimating;
  final int particleBudget;
  final int frameSkip;

  double get _salesRatio {
    if (salesTarget <= 0) return 0;
    return (salesToday / salesTarget).clamp(0.0, 1.0);
  }

  Color get _healthColor =>
      HudColors.colorForHealth(stockHealth.clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final Widget core = HudCore(
      size: 190,
      health: stockHealth.clamp(0.0, 1.0),
      particleBudget: particleBudget,
      isAnimating: isAnimating,
      frameSkip: frameSkip,
    );

    final Widget coreTempPanel = HudPanel(
      title: 'CORE TEMP',
      accent: HudColors.cyan,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HudCircularGauge(
            value: _salesRatio,
            label: 'SALES VS TARGET',
            color: HudColors.cyan,
            size: 96,
            isAnimating: isAnimating,
          ),
          const SizedBox(height: 8),
          HudCountUp(
            target: salesToday.toDouble(),
            usePkrFormat: true,
            animate: isAnimating,
            style: HudTextStyles.valueSmall,
          ),
          Text(
            'TARGET ${formatHudPkr(salesTarget)}',
            style: HudTextStyles.label,
          ),
        ],
      ),
    );

    final Widget stockPanel = HudPanel(
      title: 'STOCK CHECK',
      accent: _healthColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HudPercentBar(
            label: 'STOCK HEALTH',
            percent: stockHealth.clamp(0.0, 1.0) * 100,
            color: _healthColor,
            isAnimating: isAnimating,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Icon(
                lowStockAlerts > 0 ? Icons.warning_amber_rounded : Icons.check_circle,
                color: lowStockAlerts > 0 ? HudColors.amber : HudColors.neonGreen,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'LOW STOCK ALERTS: $lowStockAlerts',
                  style: HudTextStyles.label.copyWith(
                    color: lowStockAlerts > 0 ? HudColors.amber : HudColors.text,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final Widget cashPanel = HudPanel(
      title: 'CASH DRAWER',
      accent: HudColors.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HudCountUp(
            target: cashDrawer.toDouble(),
            usePkrFormat: true,
            animate: isAnimating,
          ),
          const Text('CASH IN DRAWER', style: HudTextStyles.label),
        ],
      ),
    );

    final Widget udhaarPanel = HudPanel(
      title: 'PENDING UDHAAR',
      accent: HudColors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HudCountUp(
            target: pendingUdhaarAmount.toDouble(),
            usePkrFormat: true,
            animate: isAnimating,
            style: HudTextStyles.value.copyWith(color: HudColors.orange),
          ),
          Text(
            '$pendingUdhaarCount CUSTOMER${pendingUdhaarCount == 1 ? '' : 'S'} PENDING',
            style: HudTextStyles.label,
          ),
        ],
      ),
    );

    final Widget syncPanel = HudPanel(
      title: 'SYNC STATUS',
      accent: isSynced ? HudColors.neonGreen : HudColors.amber,
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isSynced ? HudColors.neonGreen : HudColors.amber,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (isSynced ? HudColors.neonGreen : HudColors.amber)
                      .withValues(alpha: 0.7),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              syncStatus,
              style: HudTextStyles.valueSmall.copyWith(
                color: isSynced ? HudColors.neonGreen : HudColors.amber,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth > 720;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    coreTempPanel,
                    const SizedBox(height: 12),
                    stockPanel,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              core,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    cashPanel,
                    const SizedBox(height: 12),
                    udhaarPanel,
                    const SizedBox(height: 12),
                    syncPanel,
                  ],
                ),
              ),
            ],
          );
        }
        // Narrow screens: core on top, panels stacked below.
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            core,
            const SizedBox(height: 12),
            coreTempPanel,
            const SizedBox(height: 12),
            stockPanel,
            const SizedBox(height: 12),
            cashPanel,
            const SizedBox(height: 12),
            udhaarPanel,
            const SizedBox(height: 12),
            syncPanel,
          ],
        );
      },
    );
  }
}
