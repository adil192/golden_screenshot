import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

/// A [MaterialApp] that produces golden images
/// with [device]'s resolution, pixel ratio, and frame.
class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({
    super.key,
    this.theme,
    required this.device,
    this.frameColors,
    required this.child,
  });

  /// The theme that will be passed to [MaterialApp].
  final ThemeData? theme;

  /// The device whose resolution and pixel ratio will be simulated,
  /// and whose frame will be drawn around the [child].
  final ScreenshotDevice device;

  /// The colors of the device frame.
  final ScreenshotFrameColors? frameColors;

  /// The page that will be rendered inside the device frame.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: RepaintBoundary(
        child: SizedBox(
          width: device.resolution.width,
          height: device.resolution.height,
          child: FittedBox(
            child: SizedBox(
              width: device.resolution.width / device.pixelRatio,
              height: device.resolution.height / device.pixelRatio,
              child: MediaQuery(
                data: MediaQueryData(
                  size: device.resolution / device.pixelRatio,
                  devicePixelRatio: device.pixelRatio,
                ),
                child: MaterialApp(
                  theme: theme,
                  themeAnimationDuration: Duration.zero,
                  debugShowCheckedModeBanner: false,
                  home: device.frameBuilder(
                    device: device,
                    frameColors: frameColors,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
