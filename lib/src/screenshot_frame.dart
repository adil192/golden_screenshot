import 'package:flutter/material.dart';
import 'package:golden_screenshot/src/screenshot_device.dart';

typedef ScreenshotFrameBuilder = Widget Function({
  required ScreenshotDevice device,
  required Color? frameColor,
  required Color? onFrameColor,
  required Widget child,
});

class ScreenshotFrame extends StatelessWidget {
  const ScreenshotFrame.noFrame({
    super.key,
    required this.device,
    this.frameColor,
    this.onFrameColor,
    required this.child,
  })  : topBarImage = null,
        bottomBar = null;

  static const androidTopBarImage = AssetImage(
      'assets/topbars/android_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.android({
    super.key,
    required this.device,
    required this.frameColor,
    required this.onFrameColor,
    required this.child,
  })  : topBarImage = androidTopBarImage,
        bottomBar = const SizedBox(width: 125, height: 4);

  static const olderIphoneTopBarImage = AssetImage(
      'assets/topbars/older_iphone_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.olderIphone({
    super.key,
    required this.device,
    required this.frameColor,
    required this.onFrameColor,
    required this.child,
  })  : topBarImage = olderIphoneTopBarImage,
        bottomBar = null;

  static const newerIphoneTopBarImage = AssetImage(
      'assets/topbars/newer_iphone_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.newerIphone({
    super.key,
    required this.device,
    required this.frameColor,
    required this.onFrameColor,
    required this.child,
  })  : topBarImage = newerIphoneTopBarImage,
        bottomBar = const SizedBox(width: 150, height: 5);

  static const olderIpadTopBarImage = AssetImage(
      'assets/topbars/older_ipad_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.olderIpad({
    super.key,
    required this.device,
    required this.frameColor,
    required this.onFrameColor,
    required this.child,
  })  : topBarImage = olderIpadTopBarImage,
        bottomBar = null;

  static const newerIpadTopBarImage = AssetImage(
      'assets/topbars/newer_ipad_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.newerIpad({
    super.key,
    required this.device,
    required this.frameColor,
    required this.onFrameColor,
    required this.child,
  })  : topBarImage = newerIpadTopBarImage,
        bottomBar = const SizedBox(width: 320, height: 6);

  final ScreenshotDevice device;
  final Color? frameColor, onFrameColor;
  final ImageProvider? topBarImage;
  final SizedBox? bottomBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onFrameColor = this.onFrameColor ??
        (device.platform == TargetPlatform.android
            ? Color.lerp(colorScheme.onSurface, colorScheme.surface, 0.3)!
            : colorScheme.onSurface);
    return ColoredBox(
      color: frameColor ?? colorScheme.surface,
      child: Column(
        children: [
          if (topBarImage != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(onFrameColor, BlendMode.modulate),
              child: Image(image: topBarImage!),
            ),
          Expanded(child: child),
          if (bottomBar != null)
            SizedBox(
              height: 24,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: onFrameColor,
                  ),
                  child: bottomBar,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
