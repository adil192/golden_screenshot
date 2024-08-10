import 'package:flutter/material.dart';
import 'package:golden_screenshot/src/screenshot_frame.dart';
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
  olderIphone(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(1242, 2208),
    pixelRatio: 3,
    goldenSubFolder: 'olderIphoneScreenshots/',
    frameBuilder: ScreenshotFrame.olderIphone,
  )),

  /// iPhone 6.5" Display (the one without a home button)
  newerIphone(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(1284, 2778),
    pixelRatio: 3,
    goldenSubFolder: 'newerIphoneScreenshots/',
    frameBuilder: ScreenshotFrame.newerIphone,
  )),

  /// iPad 12.9" Display (the one with a home button)
  olderIpad(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(2048, 2732),
    pixelRatio: 2,
    goldenSubFolder: 'olderIpadScreenshots/',
    frameBuilder: ScreenshotFrame.olderIpad,
  )),

  /// iPad 13" Display (the one without a home button)
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
    return matchesGoldenFile(goldenFile);
  }
}
