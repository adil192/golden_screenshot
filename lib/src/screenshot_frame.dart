import 'package:flutter/material.dart';
import 'package:golden_screenshot/src/screenshot_device.dart';

/// A builder that can add a top and bottom bar to its [child].
typedef ScreenshotFrameBuilder = Widget Function({
  required ScreenshotDevice device,
  required ScreenshotFrameColors? frameColors,
  required Widget child,
});

/// The frame's colors can be customized with this
/// to match the content of the app.
///
/// For example, you may want the top bar to match the color of the app bar,
/// and the bottom bar to match the app's background color.
///
/// If [topBar] or [bottomBar] is null, [ColorScheme.surface] will be used.
///
/// If [onTopBar] or [onBottomBar] is null,
/// [ColorScheme.onSurface] will be used for iOS and
/// a blend of [ColorScheme.onSurface] and [ColorScheme.surface] will be used
/// for Android.
class ScreenshotFrameColors {
  const ScreenshotFrameColors({
    this.topBar,
    this.onTopBar,
    this.bottomBar,
    this.onBottomBar,
  });

  /// The background color of the top bar.
  final Color? topBar;

  /// The foreground (text and icons) color of the top bar.
  final Color? onTopBar;

  /// The background color of the bottom bar.
  final Color? bottomBar;

  /// The foreground (gesture hint) color of the bottom bar.
  final Color? onBottomBar;
}

/// A widget that draws a frame around its [child].
/// Each constructor creates a different frame.
class ScreenshotFrame extends StatelessWidget {
  /// Creates a frame with no top or bottom bar.
  const ScreenshotFrame.noFrame({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBarImage = null,
        bottomBar = null;

  /// An image of the Android status bar.
  static const androidTopBarImage = AssetImage(
      'assets/topbars/android_topbar.png',
      package: 'golden_screenshot');

  /// Creates a frame with a status bar and a navigation bar.
  const ScreenshotFrame.android({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = androidTopBarImage,
        bottomBar = const SizedBox(width: 125, height: 4);

  /// An image of the top bar of an older iPhone.
  static const olderIphoneTopBarImage = AssetImage(
      'assets/topbars/older_iphone_topbar.png',
      package: 'golden_screenshot');

  /// Creates a frame with an iPhone 5.5" top bar.
  /// There is no bottom bar because the iPhone 5.5" has a home button.
  const ScreenshotFrame.olderIphone({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = olderIphoneTopBarImage,
        bottomBar = null;

  /// An image of the top bar of a newer iPhone.
  static const newerIphoneTopBarImage = AssetImage(
      'assets/topbars/newer_iphone_topbar.png',
      package: 'golden_screenshot');

  /// Creates a frame with an iPhone 6.5" top bar and a bottom bar.
  const ScreenshotFrame.newerIphone({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = newerIphoneTopBarImage,
        bottomBar = const SizedBox(width: 150, height: 5);

  /// An image of the top bar of an older iPad.
  static const olderIpadTopBarImage = AssetImage(
      'assets/topbars/older_ipad_topbar.png',
      package: 'golden_screenshot');

  /// Creates a frame with an iPad 12.9" top bar.
  /// There is no bottom bar because the iPad 12.9" has a home button.
  const ScreenshotFrame.olderIpad({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = olderIpadTopBarImage,
        bottomBar = null;

  /// An image of the top bar of a newer iPad.
  static const newerIpadTopBarImage = AssetImage(
      'assets/topbars/newer_ipad_topbar.png',
      package: 'golden_screenshot');

  /// Creates a frame with an iPad 13" top bar and a bottom bar.
  const ScreenshotFrame.newerIpad({
    super.key,
    required this.device,
    required this.frameColors,
    required this.child,
  })  : topBarImage = newerIpadTopBarImage,
        bottomBar = const SizedBox(width: 320, height: 6);

  /// The device that this frame will simulate.
  final ScreenshotDevice device;

  /// The colors of the top and bottom bars.
  final ScreenshotFrameColors? frameColors;

  /// The image of the top bar, if any.
  final ImageProvider? topBarImage;

  /// The size of the gesture hint in the bottom bar, if any.
  final SizedBox? bottomBar;

  /// The child that will be rendered inside the frame.
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
