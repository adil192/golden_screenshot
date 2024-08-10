import 'package:flutter/material.dart';
import 'package:golden_screenshot/src/screenshot_frame.dart';

/// A device whose resolution and pixel ratio will be simulated,
/// and whose frame will be drawn in screenshots.
enum ScreenshotDevice {
  /// A desktop/laptop running Linux.
  ///
  /// The size fits Flathub's guidelines for screenshots
  /// (https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/quality-guidelines/#reasonable-window-size)
  /// while also being a 16:9 aspect ratio for Google Play.
  flathub(
    platform: TargetPlatform.linux,
    resolution: Size(1920, 1080),
    pixelRatio: 1.5,
    goldenFolder: '../metadata/en-US/images/tenInchScreenshots/',
    frameBuilder: ScreenshotFrame.noFrame,
  ),

  /// An Android phone based on the Pixel 6 Pro.
  android(
    platform: TargetPlatform.android,
    resolution: Size(1440, 3120),
    pixelRatio: 10 / 3,
    goldenFolder: '../metadata/en-US/images/phoneScreenshots/',
    frameBuilder: ScreenshotFrame.android,
  ),

  /// A MacBook Pro (15-inch, 2019)
  /// with a "scaled resolution" of 1440x900.
  macbook(
    platform: TargetPlatform.macOS,
    resolution: Size(2880, 1800),
    pixelRatio: 2,
    goldenFolder: '../metadata/en-US/images/macbookScreenshots/',
    frameBuilder: ScreenshotFrame.noFrame,
  ),

  /// iPhone 5.5" Display (the one with a home button)
  olderIphone(
    platform: TargetPlatform.iOS,
    resolution: Size(1242, 2208),
    pixelRatio: 3,
    goldenFolder: '../metadata/en-US/images/olderIphoneScreenshots/',
    frameBuilder: ScreenshotFrame.olderIphone,
  ),

  /// iPhone 6.5" Display (the one without a home button)
  newerIphone(
    platform: TargetPlatform.iOS,
    resolution: Size(1284, 2778),
    pixelRatio: 3,
    goldenFolder: '../metadata/en-US/images/newerIphoneScreenshots/',
    frameBuilder: ScreenshotFrame.newerIphone,
  ),

  /// iPad 12.9" Display (the one with a home button)
  olderIpad(
    platform: TargetPlatform.iOS,
    resolution: Size(2048, 2732),
    pixelRatio: 2,
    goldenFolder: '../metadata/en-US/images/olderIpadScreenshots/',
    frameBuilder: ScreenshotFrame.olderIpad,
  ),

  /// iPad 13" Display (the one without a home button)
  newerIpad(
    platform: TargetPlatform.iOS,
    resolution: Size(2064, 2752),
    pixelRatio: 2,
    goldenFolder: '../metadata/en-US/images/newerIpadScreenshots/',
    frameBuilder: ScreenshotFrame.newerIpad,
  );

  const ScreenshotDevice({
    required this.platform,
    required this.resolution,
    required this.pixelRatio,
    required this.goldenFolder,
    required this.frameBuilder,
  }) : assert(pixelRatio > 0);

  /// The platform/operating system of the device.
  final TargetPlatform platform;

  /// The resolution of the device in physical pixels.
  /// This is not the logical resolution.
  final Size resolution;

  /// The ratio of physical pixels to logical pixels.
  final double pixelRatio;

  /// The folder where golden files are stored.
  final String goldenFolder;

  /// The builder that creates the frame around the [child].
  final ScreenshotFrameBuilder frameBuilder;
}
