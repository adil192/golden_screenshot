import 'package:flutter/material.dart';
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
/// If these brightnesses aren't provided, they will be guessed from
/// the current theme's surface color.
class ScreenshotFrameColors {
  const ScreenshotFrameColors({
    this.topBarIconBrightness,
    this.gestureHintBrightness,
  });

  /// The foreground (text and icons) brightness of the top bar.
  final Brightness? topBarIconBrightness;

  /// The foreground (gesture hint) brightness of the bottom bar.
  final Brightness? gestureHintBrightness;

  /// Sets the foregrounds (text, icons, and gesture hint) to [Brightness.light]
  static const light = ScreenshotFrameColors(
    topBarIconBrightness: Brightness.light,
    gestureHintBrightness: Brightness.light,
  );

  /// Sets the foregrounds (text, icons, and gesture hint) to [Brightness.dark]
  static const dark = ScreenshotFrameColors(
    topBarIconBrightness: Brightness.dark,
    gestureHintBrightness: Brightness.dark,
  );
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
  })  : topBar = null,
        bottomBar = null;

  /// Creates a frame with a status bar and a navigation bar.
  const ScreenshotFrame.android({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBar = const FrameTopBar(
          topBarPhysicalHeight: 156,
          topBarImage: androidTopBarImage,
        ),
        bottomBar = const FrameBottomBar(
          bottomBarPhysicalHeight: 72,
          handlePhysicalSize: Size(324, 12),
        );

  /// Creates a frame with an iPhone 6.5" top bar and a bottom bar.
  const ScreenshotFrame.iphone({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBar = const FrameTopBar(
          topBarPhysicalHeight: 186,
          topBarImage: iphoneTopBarImage,
        ),
        bottomBar = const FrameBottomBar(
          bottomBarPhysicalHeight: 102,
          handlePhysicalSize: Size.zero,
        );

  /// Creates a frame with an iPad 13" top bar and a bottom bar.
  const ScreenshotFrame.ipad({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBar = const FrameTopBar(
          topBarPhysicalHeight: 64,
          topBarImage: ipadTopBarImage,
        ),
        bottomBar = const FrameBottomBar(
          bottomBarPhysicalHeight: 40,
          handlePhysicalSize: Size.zero,
        );

  /// The device that this frame will simulate.
  final ScreenshotDevice device;

  /// The colors of the top and bottom bars.
  final ScreenshotFrameColors? frameColors;

  /// Information about the top bar, if present.
  final FrameTopBar? topBar;

  /// Information about the bottom bar, if present.
  final FrameBottomBar? bottomBar;

  /// The child that will be rendered inside the frame.
  final Widget child;

  Brightness _getStatusBarIconBrightness(BuildContext context) {
    if (frameColors?.topBarIconBrightness != null) {
      return frameColors!.topBarIconBrightness!;
    }

    return _iconBrightnessForBackgroundColor(
        Theme.of(context).colorScheme.surface);
  }

  Brightness _getGestureHintBrightness(BuildContext context) {
    if (frameColors?.gestureHintBrightness != null) {
      return frameColors!.gestureHintBrightness!;
    }

    return _iconBrightnessForBackgroundColor(
        Theme.of(context).colorScheme.surface);
  }

  Brightness _iconBrightnessForBackgroundColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Brightness.dark
        : Brightness.light;
  }

  Color _getIconColor(BuildContext context, Brightness iconBrightness) {
    final theme = Theme.of(context);
    if (theme.brightness == iconBrightness) {
      return theme.colorScheme.surface;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topBarLogicalHeight =
        (topBar?.topBarPhysicalHeight ?? 0) / mediaQuery.devicePixelRatio;
    final bottomBarLogicalHeight =
        (bottomBar?.bottomBarPhysicalHeight ?? 0) / mediaQuery.devicePixelRatio;

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: EdgeInsets.only(
          top: topBarLogicalHeight,
          bottom: bottomBarLogicalHeight,
        ),
        viewPadding: EdgeInsets.only(
          top: topBarLogicalHeight,
          bottom: bottomBarLogicalHeight,
        ),
      ),
      child: Stack(
        children: [
          child,
          if (topBarLogicalHeight > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topBarLogicalHeight,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _getIconColor(
                    context,
                    _getStatusBarIconBrightness(context),
                  ),
                  BlendMode.srcIn,
                ),
                child: Image(image: topBar!.topBarImage),
              ),
            ),
          if (bottomBarLogicalHeight > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bottomBarLogicalHeight,
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
                    width: bottomBar!.handlePhysicalSize.width /
                        mediaQuery.devicePixelRatio,
                    height: bottomBar!.handlePhysicalSize.height /
                        mediaQuery.devicePixelRatio,
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

  /// An image of the top bar of an iPhone.
  static const iphoneTopBarImage = AssetImage(
      'assets/topbars/iphone_topbar.png',
      package: 'golden_screenshot');

  /// An image of the top bar of an iPad.
  static const ipadTopBarImage = AssetImage('assets/topbars/ipad_topbar.png',
      package: 'golden_screenshot');
}

class FrameTopBar {
  const FrameTopBar({
    required this.topBarPhysicalHeight,
    required this.topBarImage,
  });

  /// The size of the top bar in physical pixels.
  ///
  /// This will be divided by the device pixel ratio to get the logical size.
  final double topBarPhysicalHeight;

  /// The image of the top bar.
  final ImageProvider topBarImage;
}

class FrameBottomBar {
  const FrameBottomBar({
    required this.bottomBarPhysicalHeight,
    required this.handlePhysicalSize,
  });

  /// The size of the bottom bar in physical pixels.
  ///
  /// This will be divided by the device pixel ratio to get the logical size.
  final double bottomBarPhysicalHeight;

  /// The size of the gesture handle in physical pixels.
  ///
  /// This will be divided by the device pixel ratio to get the logical size.
  final Size handlePhysicalSize;
}
