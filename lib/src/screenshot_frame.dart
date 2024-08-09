import 'package:flutter/material.dart';
import 'package:golden_screenshot/src/screenshot_device.dart';

typedef ScreenshotFrameBuilder = Widget Function({
  required ScreenshotDevice device,
  required ScreenshotFrameColors? frameColors,
  required Widget child,
});

class ScreenshotFrameColors {
  const ScreenshotFrameColors({
    this.topBar,
    this.onTopBar,
    this.bottomBar,
    this.onBottomBar,
  });

  final Color? topBar, onTopBar, bottomBar, onBottomBar;
}

class ScreenshotFrame extends StatelessWidget {
  const ScreenshotFrame.noFrame({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBarImage = null,
        bottomBar = null;

  static const androidTopBarImage = AssetImage(
      'assets/topbars/android_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.android({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = androidTopBarImage,
        bottomBar = const SizedBox(width: 125, height: 4);

  static const olderIphoneTopBarImage = AssetImage(
      'assets/topbars/older_iphone_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.olderIphone({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = olderIphoneTopBarImage,
        bottomBar = null;

  static const newerIphoneTopBarImage = AssetImage(
      'assets/topbars/newer_iphone_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.newerIphone({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = newerIphoneTopBarImage,
        bottomBar = const SizedBox(width: 150, height: 5);

  static const olderIpadTopBarImage = AssetImage(
      'assets/topbars/older_ipad_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.olderIpad({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = olderIpadTopBarImage,
        bottomBar = null;

  static const newerIpadTopBarImage = AssetImage(
      'assets/topbars/newer_ipad_topbar.png',
      package: 'golden_screenshot');
  const ScreenshotFrame.newerIpad({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = newerIpadTopBarImage,
        bottomBar = const SizedBox(width: 320, height: 6);

  final ScreenshotDevice device;
  final ScreenshotFrameColors? frameColors;
  final ImageProvider? topBarImage;
  final SizedBox? bottomBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    /// The color used if [frameColors] doesn't specify an `onTopBar` or
    /// `onBottomBar` color.
    late final fallbackOnFrameBar = device.platform == TargetPlatform.android
        ? Color.lerp(colorScheme.onSurface, colorScheme.surface, 0.3)!
        : colorScheme.onSurface;

    return Column(
      children: [
        if (topBarImage != null)
          ColoredBox(
            color: frameColors?.topBar ?? colorScheme.surface,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                frameColors?.onTopBar ?? fallbackOnFrameBar,
                BlendMode.modulate,
              ),
              child: Image(image: topBarImage!),
            ),
          ),
        Expanded(child: child),
        if (bottomBar != null)
          SizedBox(
            height: 24,
            child: ColoredBox(
              color: frameColors?.bottomBar ?? colorScheme.surface,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: frameColors?.onBottomBar ?? fallbackOnFrameBar,
                  ),
                  child: bottomBar,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
