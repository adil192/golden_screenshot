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

  final ThemeData? theme;
  final ScreenshotDevice device;
  final ScreenshotFrameColors? frameColors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      debugShowCheckedModeBanner: false,
      home: FittedBox(
        child: RepaintBoundary(
          child: SizedBox(
            width: device.resolution.width,
            height: device.resolution.height,
            child: FittedBox(
              child: SizedBox(
                width: device.resolution.width / device.pixelRatio,
                height: device.resolution.height / device.pixelRatio,
                child: device.frameBuilder(
                  device: device,
                  frameColors: frameColors,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
