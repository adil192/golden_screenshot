import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

/// The default set of [ScreenshotDevice]s.
///
/// See [GoldenSmallDevices] for the equivalent devices at a lower resolution
/// to speed up tests.
enum GoldenScreenshotDevices {
  /// A desktop/laptop running Linux.
  ///
  /// The size fits Flathub's guidelines for screenshots
  /// (https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/quality-guidelines/#reasonable-window-size).
  flathub(ScreenshotDevice(
    platform: TargetPlatform.linux,
    resolution: Size(1000 + flathubMargin * 2, 700 + flathubMargin * 2),
    pixelRatio: 1,
    goldenSubFolder: 'flathubScreenshots/',
    frameBuilder: ScreenshotFrame.flathub,
  )),

  /// An Android phone based on the Pixel 9 Pro.
  androidPhone(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(1280, 2856),
    pixelRatio: 3,
    goldenSubFolder: 'phoneScreenshots/',
    frameBuilder: ScreenshotFrame.androidPhone,
  )),

  /// An Android tablet based on the Samsung Galaxy Tab S11,
  /// but with a 16:9 aspect ratio to meet Play Store requirements.
  androidTablet(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(2560, 1440),
    pixelRatio: 1.5,
    goldenSubFolder: 'tenInchScreenshots/',
    frameBuilder: ScreenshotFrame.androidTablet,
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
  @Deprecated('Use `androidPhone` instead')
  static GoldenScreenshotDevices get android => androidPhone;
}

@Deprecated('Use GoldenScreenshotDevices instead.')
class ScreenshotDevices {
  static List<ScreenshotDevice> get values =>
      GoldenScreenshotDevices.values.map((e) => e.device).toList();
}

/// Devices with a small resolution for fast testing.
///
/// See [GoldenScreenshotDevices] for the full resolution equivalents.
enum GoldenSmallDevices {
  /// A desktop/laptop running Linux.
  ///
  /// The size fits Flathub's guidelines for screenshots
  /// (https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/quality-guidelines/#reasonable-window-size).
  flathub(ScreenshotDevice(
    platform: TargetPlatform.linux,
    resolution:
        Size((1000 + flathubMargin * 2) * sf, (700 + flathubMargin * 2) * sf),
    pixelRatio: 1 * sf,
    goldenSubFolder: 'flathubScreenshots/',
    frameBuilder: ScreenshotFrame.flathub,
  )),

  /// An Android phone based on the Pixel 9 Pro.
  androidPhone(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(1280 * sf, 2856 * sf),
    pixelRatio: 3 * sf,
    goldenSubFolder: 'phoneScreenshots/',
    frameBuilder: ScreenshotFrame.androidPhone,
  )),

  /// An Android tablet based on the Samsung Galaxy Tab S11,
  /// but with a 16:9 aspect ratio to meet Play Store requirements.
  androidTablet(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(2560 * sf, 1440 * sf),
    pixelRatio: 1.5 * sf,
    goldenSubFolder: 'tenInchScreenshots/',
    frameBuilder: ScreenshotFrame.androidTablet,
  )),

  /// A MacBook Pro (15-inch, 2019)
  /// with a "scaled resolution" of 1440x900.
  macbook(ScreenshotDevice(
    platform: TargetPlatform.macOS,
    resolution: Size(2880 * sf, 1800 * sf),
    pixelRatio: 2 * sf,
    goldenSubFolder: 'macbookScreenshots/',
    frameBuilder: ScreenshotFrame.noFrame,
  )),

  /// iPhone 16 Pro Max,
  /// labelled on App Store Connect as iPhone 6.9" Display.
  iphone(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(1320 * sf, 2868 * sf),
    pixelRatio: 3 * sf,
    goldenSubFolder: 'iphoneScreenshots/',
    frameBuilder: ScreenshotFrame.iphone,
  )),

  /// iPad Pro 13" (M4),
  /// labelled on App Store Connect as iPad 13" Display.
  ipad(ScreenshotDevice(
    platform: TargetPlatform.iOS,
    resolution: Size(2064 * sf, 2752 * sf),
    pixelRatio: 2 * sf,
    goldenSubFolder: 'ipadScreenshots/',
    frameBuilder: ScreenshotFrame.ipad,
  ));

  const GoldenSmallDevices(this.device);
  final ScreenshotDevice device;

  /// The scale factor applied to each device's resolution.
  @visibleForTesting
  static const sf = 0.2;

  @Deprecated('Use `androidPhone` instead')
  static GoldenSmallDevices get android => androidPhone;
}
