import 'package:flutter/widgets.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

/// Sets the size and [mediaQueryData] of its child to simulate a device with
/// the given [resolution] and [pixelRatio].
///
/// You don't need to use this widget directly if you're using [ScreenshotApp].
class DeviceBox extends StatelessWidget {
  const DeviceBox.fromValues({
    super.key,
    required this.resolution,
    required this.pixelRatio,
    this.mediaQueryData = _defaultMediaQueryData,
    required this.child,
  });

  DeviceBox.fromDevice({
    super.key,
    required ScreenshotDevice device,
    this.mediaQueryData = _defaultMediaQueryData,
    required this.child,
  }) : resolution = device.resolution,
       pixelRatio = device.pixelRatio;

  static const _defaultMediaQueryData = MediaQueryData(disableAnimations: true);

  /// The physical resolution of the screen in pixels.
  ///
  /// This will be divided by [pixelRatio] to get the logical
  /// [MediaQueryData.size].
  ///
  /// For example, a 1440p resolution device with a pixel ratio of 2 has a
  /// logical size of 720p.
  final Size resolution;

  /// The device pixel ratio, [MediaQueryData.devicePixelRatio].
  ///
  /// Increase the pixel ratio to make UI elements appear bigger.
  final double pixelRatio;

  /// The [MediaQueryData] to provide to the [child].
  ///
  /// This will be modified to have the correct size and pixel ratio.
  final MediaQueryData mediaQueryData;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: RepaintBoundary(
        child: SizedBox(
          width: resolution.width,
          height: resolution.height,
          child: FittedBox(
            child: SizedBox(
              width: resolution.width / pixelRatio,
              height: resolution.height / pixelRatio,
              child: MediaQuery(
                data: mediaQueryData.copyWith(
                  size: resolution / pixelRatio,
                  devicePixelRatio: pixelRatio,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
