import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:golden_screenshot/src/screenshot_frame.dart';
import 'package:path/path.dart' as p;
// ignore: implementation_imports
import 'package:matcher/src/expect/async_matcher.dart' show AsyncMatcher;

/// The default set of [ScreenshotDevice]s.
enum GoldenScreenshotDevices {
  /// A desktop/laptop running Linux.
  ///
  /// The size fits Flathub's guidelines for screenshots
  /// (https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/quality-guidelines/#reasonable-window-size)
  /// while also being a 16:9 aspect ratio for Google Play.
  flathub(ScreenshotDevice(
    platform: TargetPlatform.linux,
    resolution: Size(1920, 1080),
    pixelRatio: 1.5,
    goldenSubFolder: 'tenInchScreenshots/',
    frameBuilder: ScreenshotFrame.noFrame,
  )),

  /// An Android phone based on the Pixel 6 Pro.
  android(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(1440, 3120),
    pixelRatio: 10 / 3,
    goldenSubFolder: 'phoneScreenshots/',
    frameBuilder: ScreenshotFrame.android,
  )),

  /// A MacBook Pro (15-inch, 2019)
  /// with a "scaled resolution" of 1440x900.
  macbook(ScreenshotDevice(
    platform: TargetPlatform.macOS,
    resolution: Size(2880, 1800),
    pixelRatio: 2,
    goldenSubFolder: 'macbookScreenshots/',
    frameBuilder: ScreenshotFrame.noFrame,
  )),

  /// iPhone 5.5" Display (the one with a home button)
  /// based on the iPhone 8 Plus.
  olderIphone(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(1242, 2208),
    pixelRatio: 3,
    goldenSubFolder: 'olderIphoneScreenshots/',
    frameBuilder: ScreenshotFrame.olderIphone,
  )),

  /// iPhone 6.9" Display (the one without a home button)
  /// based on the iPhone 16 Pro Max.
  newerIphone(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(1320, 2868),
    pixelRatio: 3,
    goldenSubFolder: 'newerIphoneScreenshots/',
    frameBuilder: ScreenshotFrame.newerIphone,
  )),

  /// iPad Pro 12.9" (2nd generation),
  /// labelled on App Store Connect as iPad 12.9" Display.
  ///
  /// This is the older type of iPad with thicker bezels and a home button.
  olderIpad(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(2048, 2732),
    pixelRatio: 2,
    goldenSubFolder: 'olderIpadScreenshots/',
    frameBuilder: ScreenshotFrame.olderIpad,
  )),

  /// iPad Pro 13" (M4),
  /// labelled on App Store Connect as iPad 13" Display.
  ///
  /// This is the newer type of iPad with thinner bezels and no home button.
  newerIpad(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(2064, 2752),
    pixelRatio: 2,
    goldenSubFolder: 'newerIpadScreenshots/',
    frameBuilder: ScreenshotFrame.newerIpad,
  ));

  const GoldenScreenshotDevices(this.device);
  final ScreenshotDevice device;
}

@Deprecated('Use GoldenScreenshotDevices instead.')
class ScreenshotDevices {
  static List<ScreenshotDevice> get values =>
      GoldenScreenshotDevices.values.map((e) => e.device).toList();
}

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
  final String goldenSubFolder;

  /// The builder that creates the frame around the [child].
  final ScreenshotFrameBuilder frameBuilder;

  /// This folder will contain subfolders for each device's screenshots.
  /// Use `\${langCode}` as a placeholder for the language code,
  /// if needed.
  ///
  /// This path is relative to the `test` folder.
  static String screenshotsFolder = '../metadata/\${langCode}/images';

  /// Returns a `matchesGoldenFile` matcher for the relevant golden file.
  /// Use [goldenFilePath] to override the path to the golden file.
  AsyncMatcher matchesGoldenFile(String goldenFileName, {String? langCode, String? goldenFilePath}) {
    final fileName = '$goldenFileName.png';

    if (goldenFilePath != null) {
      final goldenFile = p.join(goldenFilePath, fileName);
      return flutter_test.matchesGoldenFile(goldenFile);
    }

    final goldenFile = p
        .join(ScreenshotDevice.screenshotsFolder, goldenSubFolder, fileName)
        .replaceFirst('\${langCode}', langCode ?? 'en-US');

    return flutter_test.matchesGoldenFile(goldenFile);
  }
}
