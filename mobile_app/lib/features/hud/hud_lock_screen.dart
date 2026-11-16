import 'package:flutter/material.dart';

import 'data_rain.dart';
import 'hud_background.dart';
import 'hud_core.dart';
import 'hud_theme.dart';

/// Full-screen HUD lock screen shown after inactivity (auto-lock is
/// 2 minutes by default, DECISIONS.md #11; Round 2 wires the
/// inactivity handler to this widget).
///
/// Shows [HudBackground] + [HudCore] + [DataRain] scrolling the real
/// bill/IMEI fragments passed in via [rainValues], a "SYSTEM LOCKED"
/// heading and an Unlock button.
///
/// Unlocking calls [onUnlock] — the caller performs biometric/PIN
/// verification via local_auth. This widget does NOT implement
/// biometric itself. While [isUnlocking] is true the button shows a
/// spinner and is disabled.
class HudLockScreen extends StatelessWidget {
  const HudLockScreen({
    super.key,
    required this.rainValues,
    required this.onUnlock,
    this.isUnlocking = false,
    this.isAnimating = true,
    this.lockedMessage = 'SYSTEM LOCKED',
    this.hint = 'Tap UNLOCK to verify and continue',
  });

  /// Real values for the data rain (bill numbers, IMEI fragments,
  /// amounts). Never random text.
  final List<String> rainValues;

  /// Called when the user taps Unlock; the caller runs biometric/PIN.
  final VoidCallback onUnlock;

  /// True while the caller is verifying (button disabled + spinner).
  final bool isUnlocking;
  final bool isAnimating;
  final String lockedMessage;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return HudBackground(
      isAnimating: isAnimating,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Data rain along both edges, low-key behind the centre.
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 92,
              child: Opacity(
                opacity: 0.5,
                child: DataRain(
                  values: rainValues,
                  columns: 2,
                  isAnimating: isAnimating,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 92,
              child: Opacity(
                opacity: 0.5,
                child: DataRain(
                  values: rainValues.reversed.toList(),
                  columns: 2,
                  isAnimating: isAnimating,
                  height: double.infinity,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  HudCore(
                    size: 170,
                    health: 1.0,
                    particleBudget: isAnimating ? 250 : 0,
                    isAnimating: isAnimating,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lockedMessage,
                    style: HudTextStyles.title.copyWith(
                      fontSize: 20,
                      letterSpacing: 5,
                      color: HudColors.cyan,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: HudTextStyles.label,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 220,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isUnlocking ? null : onUnlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HudColors.cyan,
                        foregroundColor: HudColors.background,
                        disabledBackgroundColor:
                            HudColors.cyan.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: isUnlocking
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: HudColors.background,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'UNLOCKING...',
                                  style: TextStyle(
                                    fontFamily: HudTextStyles.monoFamily,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'UNLOCK',
                              style: TextStyle(
                                fontFamily: HudTextStyles.monoFamily,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
