import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

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
