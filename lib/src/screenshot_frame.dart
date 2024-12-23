import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golden_screenshot/src/screenshot_device.dart';

/// A builder that can add a top and bottom bar to its [child].
///
/// It should also set [MediaQueryData.padding] so that [SafeArea]s work.
typedef ScreenshotFrameBuilder = Widget Function({
  required ScreenshotDevice device,
  required ScreenshotFrameColors? frameColors,
  required Widget child,
});

/// The frame's colors can be customized with this
/// to match the content of the app.
///
/// These colors, if provided, will override the built-in [SystemChrome].
class ScreenshotFrameColors {
  const ScreenshotFrameColors({
    this.topBarIconBrightness,
    this.gestureHintBrightness,
  });

  /// The foreground (text and icons) brightness of the top bar.
  final Brightness? topBarIconBrightness;

  /// The foreground (gesture hint) brightness of the bottom bar.
  final Brightness? gestureHintBrightness;
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
  })  : topBarSize = null,
        topBarImage = null,
        gestureHintSize = null;

  /// Creates a frame with a status bar and a navigation bar.
  const ScreenshotFrame.android({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBarSize = const Size(1440, 148),
        topBarImage = androidTopBarImage,
        gestureHintSize = const Size(125, 4);

  /// Creates a frame with an iPhone 5.5" top bar.
  /// There is no bottom bar because the iPhone 5.5" has a home button.
  const ScreenshotFrame.olderIphone({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBarSize = const Size(1242, 54),
        topBarImage = olderIphoneTopBarImage,
        gestureHintSize = null;

  /// Creates a frame with an iPhone 6.5" top bar and a bottom bar.
  const ScreenshotFrame.newerIphone({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBarSize = const Size(1284, 106),
        topBarImage = newerIphoneTopBarImage,
        gestureHintSize = const Size(150, 5);

  /// Creates a frame with an iPad 12.9" top bar.
  /// There is no bottom bar because the iPad 12.9" has a home button.
  const ScreenshotFrame.olderIpad({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBarSize = const Size(2048, 39),
        topBarImage = olderIpadTopBarImage,
        gestureHintSize = null;

  /// Creates a frame with an iPad 13" top bar and a bottom bar.
  const ScreenshotFrame.newerIpad({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBarSize = const Size(2064, 50),
        topBarImage = newerIpadTopBarImage,
        gestureHintSize = const Size(320, 6);

  /// The device that this frame will simulate.
  final ScreenshotDevice device;

  /// The colors of the top and bottom bars.
  final ScreenshotFrameColors? frameColors;

  // The size of the top bar, if any.
  final Size? topBarSize;

  /// The image of the top bar, if any.
  /// This will have the same size as [topBarSize].
  final ImageProvider? topBarImage;

  /// The size of the gesture hint in the bottom bar, if any.
  /// This is the size of the hint, not the bar itself.
  final Size? gestureHintSize;

  /// The child that will be rendered inside the frame.
  final Widget child;

  Brightness _getStatusBarIconBrightness(BuildContext context) {
    if (frameColors?.topBarIconBrightness != null) {
      return frameColors!.topBarIconBrightness!;
    }

    // ignore: invalid_use_of_visible_for_testing_member
    final systemStyle = SystemChrome.latestStyle;
    if (systemStyle != null) {
      if (systemStyle.statusBarIconBrightness != null) {
        return systemStyle.statusBarIconBrightness!;
      }
      if (systemStyle.statusBarBrightness != null) {
        return systemStyle.statusBarBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
      }
    }

    return _iconBrightnessForBackgroundColor(
      systemStyle?.statusBarColor ?? Theme.of(context).colorScheme.surface,
    );
  }

  Brightness _getGestureHintBrightness(BuildContext context) {
    if (frameColors?.gestureHintBrightness != null) {
      return frameColors!.gestureHintBrightness!;
    }

    // ignore: invalid_use_of_visible_for_testing_member
    final systemStyle = SystemChrome.latestStyle;
    if (systemStyle != null) {
      if (systemStyle.systemNavigationBarIconBrightness != null) {
        return systemStyle.systemNavigationBarIconBrightness!;
      }
    }

    return _iconBrightnessForBackgroundColor(
      systemStyle?.systemNavigationBarColor ??
          Theme.of(context).colorScheme.surface,
    );
  }

  Brightness _iconBrightnessForBackgroundColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Brightness.dark
        : Brightness.light;
  }

  Color _getIconColor(BuildContext context, Brightness iconBrightness) {
    if (Theme.of(context).brightness == iconBrightness) {
      // We can't use the theme's colors since the brightness is different.
      return iconBrightness == Brightness.dark ? Colors.black : Colors.white;
    }

    final colorScheme = Theme.of(context).colorScheme;
    if (Theme.of(context).platform == TargetPlatform.android) {
      return Color.lerp(colorScheme.onSurface, colorScheme.surface, 0.3)!;
    } else {
      return colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final logicalTopBarHeight = topBarSize == null
        ? 0.0
        : topBarSize!.height / topBarSize!.width * mediaQuery.size.width;
    final logicalBottomBarHeight = gestureHintSize == null ? 0.0 : 24.0;

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: EdgeInsets.only(
          top: logicalTopBarHeight,
          bottom: logicalBottomBarHeight,
        ),
        viewPadding: EdgeInsets.only(
          top: logicalTopBarHeight,
          bottom: logicalBottomBarHeight,
        ),
      ),
      child: Stack(
        children: [
          child,
          if (logicalTopBarHeight > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: logicalTopBarHeight,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _getIconColor(
                    context,
                    _getStatusBarIconBrightness(context),
                  ),
                  BlendMode.modulate,
                ),
                child: Image(image: topBarImage!),
              ),
            ),
          if (logicalBottomBarHeight > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: logicalBottomBarHeight,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _getIconColor(
                      context,
                      _getGestureHintBrightness(context),
                    ),
                  ),
                  child: SizedBox(
                    width: gestureHintSize!.width,
                    height: gestureHintSize!.height,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// An image of the Android status bar.
  static const androidTopBarImage = AssetImage(
      'assets/topbars/android_topbar.png',
      package: 'golden_screenshot');

  /// An image of the top bar of an older iPhone.
  static const olderIphoneTopBarImage = AssetImage(
      'assets/topbars/older_iphone_topbar.png',
      package: 'golden_screenshot');

  /// An image of the top bar of a newer iPhone.
  static const newerIphoneTopBarImage = AssetImage(
      'assets/topbars/newer_iphone_topbar.png',
      package: 'golden_screenshot');

  /// An image of the top bar of an older iPad.
  static const olderIpadTopBarImage = AssetImage(
      'assets/topbars/older_ipad_topbar.png',
      package: 'golden_screenshot');

  /// An image of the top bar of a newer iPad.
  static const newerIpadTopBarImage = AssetImage(
      'assets/topbars/newer_ipad_topbar.png',
      package: 'golden_screenshot');
}
