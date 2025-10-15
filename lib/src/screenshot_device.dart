import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:golden_screenshot/src/screenshot_frame.dart';
// ignore: implementation_imports
import 'package:matcher/src/expect/async_matcher.dart' show AsyncMatcher;

/// A device whose resolution and pixel ratio will be simulated,
/// and whose frame will be drawn in screenshots.
class ScreenshotDevice {
  const ScreenshotDevice({
    required this.platform,
    required this.resolution,
    required this.pixelRatio,
    required this.goldenSubFolder,
    required this.frameBuilder,
  }) : assert(pixelRatio > 0);

  /// The platform/operating system of the device.
  final TargetPlatform platform;

  /// The resolution of the device in physical pixels.
  /// This is not the logical resolution.
  final Size resolution;

  /// The ratio of physical pixels to logical pixels.
  final double pixelRatio;

  /// The folder inside [screenshotsFolder] where the
  /// screenshots for this device are stored.
  ///
  /// This should end with a slash.
  final String goldenSubFolder;

  /// The builder that creates the frame around the [child].
  final ScreenshotFrameBuilder frameBuilder;

  /// This folder will contain subfolders for each device's screenshots.
  /// Use `\$langCode` as a placeholder for the language code,
  /// if needed.
  ///
  /// This path is relative to the `test` folder, and should end with a slash.
  static String screenshotsFolder = '../metadata/\$langCode/images/';

  /// Returns a `matchesGoldenFile` matcher for the relevant golden file.
  AsyncMatcher matchesGoldenFile(String goldenFileName, {String? langCode}) {
    final screenshotsFolder = ScreenshotDevice.screenshotsFolder
        .replaceFirst('\$langCode', langCode ?? 'en-US');

    assert(screenshotsFolder.endsWith('/'),
        'screenshotsFolder must end with a slash: $screenshotsFolder');
    assert(goldenSubFolder.endsWith('/'),
        'goldenSubFolder must end with a slash: $goldenSubFolder');

    final goldenFile = '$screenshotsFolder$goldenSubFolder$goldenFileName.png';
    return flutter_test.matchesGoldenFile(goldenFile);
  }
}
