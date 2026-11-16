import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'hud_background.dart';
import 'hud_theme.dart';

/// Optional looping video background for the HUD (DECISIONS.md #44).
///
/// * Plays a muted, looped H.264 clip ([videoAssetPath] for a bundled
///   asset such as `assets/hud_loop.mp4`, or [videoFilePath] for a
///   file on the device). No video file is bundled by default.
/// * Pauses when the widget is not visible ([isVisible] false, set
///   by the caller when the screen is covered) or when the app is
///   backgrounded (via [AppLifecycleState]).
/// * Shows [fallback] (default: [HudBackground]) when no video is
///   set or when the player fails to initialise — the HUD never
///   shows a black/blank background because of a video problem.
///
/// NOTE: `VisibilityDetector` (visibility_detector package) is not in
/// pubspec.yaml, so visibility is driven by the [isVisible] flag and
/// the app lifecycle instead. Round 2 can pass `isVisible` from the
/// router / navigator observer.
class HudVideoBackground extends StatefulWidget {
  const HudVideoBackground({
    super.key,
    this.videoAssetPath,
    this.videoFilePath,
    this.fallback,
    this.isVisible = true,
    this.isAnimating = true,
    this.fit = BoxFit.cover,
    this.child,
  });

  /// Bundled asset path, e.g. 'assets/hud_loop.mp4'. Takes priority
  /// over [videoFilePath] when both are set.
  final String? videoAssetPath;

  /// Absolute file path on the device.
  final String? videoFilePath;

  /// Shown when no video is set or the player fails. Defaults to a
  /// plain [HudBackground].
  final Widget? fallback;

  /// False when the screen using this background is covered/hidden;
  /// the video pauses. The caller drives this (e.g. from route
  /// awareness); defaults to true.
  final bool isVisible;

  /// False freezes the fallback background's animation too.
  final bool isAnimating;

  final BoxFit fit;

  /// Optional content drawn on top of the video/fallback.
  final Widget? child;

  @override
  State<HudVideoBackground> createState() => _HudVideoBackgroundState();
}

class _HudVideoBackgroundState extends State<HudVideoBackground>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _initialised = false;
  bool _failed = false;
  bool _appResumed = true;

  bool get _shouldPlay =>
      _initialised &&
      !_failed &&
      widget.isVisible &&
      _appResumed &&
      widget.isAnimating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant HudVideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAssetPath != widget.videoAssetPath ||
        oldWidget.videoFilePath != widget.videoFilePath) {
      _disposePlayer();
      _initPlayer();
    } else {
      _applyPlayState();
    }
  }

  Future<void> _initPlayer() async {
    final String? assetPath = widget.videoAssetPath;
    final String? filePath = widget.videoFilePath;
    if ((assetPath == null || assetPath.isEmpty) &&
        (filePath == null || filePath.isEmpty)) {
      // No video set: fallback only. Not an error.
      return;
    }
    final VideoPlayerController controller = assetPath != null && assetPath.isNotEmpty
        ? VideoPlayerController.asset(assetPath)
        : VideoPlayerController.file(File(filePath!));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(0); // Muted, always.
      await controller.setLooping(true);
      if (!mounted) return;
      setState(() => _initialised = true);
      _applyPlayState();
    } catch (_) {
      // Any player failure -> fall back silently to the HUD background.
      if (!mounted) return;
      setState(() => _failed = true);
      _disposePlayer();
    }
  }

  void _applyPlayState() {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !_initialised) return;
    if (_shouldPlay) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  void _disposePlayer() {
    _controller?.dispose();
    _controller = null;
    _initialised = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _applyPlayState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget fallback = widget.fallback ??
        HudBackground(isAnimating: widget.isAnimating);
    final bool showVideo = _initialised && !_failed && _controller != null;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        fallback,
        if (showVideo)
          FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        if (showVideo)
          // Subtle dark tint so HUD text stays readable (WCAG AA)
          // over bright video frames.
          Container(color: HudColors.background.withValues(alpha: 0.45)),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}
