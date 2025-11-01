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
  const ScreenshotFrame.androidPhone({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBar = const FrameTopBar(
          height: 156 / 3,
          image: androidPhoneTopBarImage,
        ),
        bottomBar = const FrameBottomBar(
          height: 72 / 3,
          handleSize: Size(324 / 3, 12 / 3),
        );

  @Deprecated('This has been renamed to `ScreenshotFrame.androidPhone`')
  const ScreenshotFrame.android({
    Key? key,
    required ScreenshotDevice device,
    ScreenshotFrameColors? frameColors,
    required Widget child,
  }) : this.androidPhone(
          key: key,
          device: device,
          frameColors: frameColors,
          child: child,
        );

  /// Creates a frame with an iPhone 6.5" top bar and a bottom bar.
  const ScreenshotFrame.iphone({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBar = const FrameTopBar(
          height: 186 / 3,
          image: iphoneTopBarImage,
        ),
        bottomBar = const FrameBottomBar(
          height: 102 / 3,
          handleSize: Size.zero,
        );

  /// Creates a frame with an iPad 13" top bar and a bottom bar.
  const ScreenshotFrame.ipad({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  })  : topBar = const FrameTopBar(
          height: 64 / 2,
          image: ipadTopBarImage,
        ),
        bottomBar = const FrameBottomBar(
          height: 40 / 2,
          handleSize: Size.zero,
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
    final viewPadding = EdgeInsets.only(
      top: topBar?.height ?? 0,
      bottom: bottomBar?.height ?? 0,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: viewPadding,
        viewPadding: viewPadding,
      ),
      child: Stack(
        children: [
          child,
          if (topBar != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topBar!.height,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _getIconColor(
                    context,
                    _getStatusBarIconBrightness(context),
                  ),
                  BlendMode.srcIn,
                ),
                child: Image(image: topBar!.image),
              ),
            ),
          if (bottomBar != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bottomBar!.height,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _getIconColor(
                      context,
                      _getGestureHintBrightness(context),
                    ),
                  ),
                  child: SizedBox.fromSize(size: bottomBar!.handleSize),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// An image of the top bar of an Android phone.
  static const androidPhoneTopBarImage = AssetImage(
      'assets/topbars/android_phone_topbar.png',
      package: 'golden_screenshot');

  /// An image of the top bar of an iPhone.
  static const iphoneTopBarImage = AssetImage(
      'assets/topbars/iphone_topbar.png',
      package: 'golden_screenshot');

  /// An image of the top bar of an iPad.
  static const ipadTopBarImage = AssetImage('assets/topbars/ipad_topbar.png',
      package: 'golden_screenshot');

  @Deprecated('This has been renamed to `androidPhoneTopBarImage`')
  static AssetImage get androidTopBarImage => androidPhoneTopBarImage;
}

class FrameTopBar {
  const FrameTopBar({
    required this.height,
    required this.image,
  }) : assert(height > 0);

  /// The size of the top bar in logical pixels.
  final double height;

  /// The image of the top bar.
  final ImageProvider image;
}

class FrameBottomBar {
  const FrameBottomBar({
    required this.height,
    required this.handleSize,
  }) : assert(height > 0);

  /// The size of the bottom bar in logical pixels.
  final double height;

  /// The size of the gesture handle in logical pixels.
  final Size handleSize;
}
