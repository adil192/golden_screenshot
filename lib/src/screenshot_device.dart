import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
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

  /// iPhone 16 Pro Max,
  /// labelled on App Store Connect as iPhone 6.9" Display.
  iphone(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(1320, 2868),
    pixelRatio: 3,
    goldenSubFolder: 'iphoneScreenshots/',
    frameBuilder: ScreenshotFrame.iphone,
  )),

  /// iPad Pro 13" (M4),
  /// labelled on App Store Connect as iPad 13" Display.
  ipad(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(2064, 2752),
    pixelRatio: 2,
    goldenSubFolder: 'ipadScreenshots/',
    frameBuilder: ScreenshotFrame.ipad,
  ));

  const GoldenScreenshotDevices(this.device);
  final ScreenshotDevice device;

  @Deprecated('Use `iphone` instead')
  static GoldenScreenshotDevices get newerIphone => iphone;
  @Deprecated('Use `iphone` instead')
  static GoldenScreenshotDevices get olderIphone => iphone;
  @Deprecated('Use `ipad` instead')
  static GoldenScreenshotDevices get newerIpad => ipad;
  @Deprecated('Use `ipad` instead')
  static GoldenScreenshotDevices get olderIpad => ipad;
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
    return flutter_test.matchesGoldenFile(goldenFile);
  }
}
