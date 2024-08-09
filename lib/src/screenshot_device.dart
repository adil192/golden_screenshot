import 'package:flutter/material.dart';
import 'package:golden_screenshot/src/screenshot_frame.dart';

enum ScreenshotDevice {
  flathub(
    platform: TargetPlatform.linux,
    resolution: Size(2000, 1400),
    pixelRatio: 2,
    goldenFolder: '../metadata/en-US/images/tenInchScreenshots/',
    frameBuilder: ScreenshotFrame.noFrame,
  ),

  android(
    platform: TargetPlatform.android,
    resolution: Size(1440, 3120),
    pixelRatio: 10 / 3,
    goldenFolder: '../metadata/en-US/images/phoneScreenshots/',
    frameBuilder: ScreenshotFrame.android,
  ),

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

  final TargetPlatform platform;
  final Size resolution;
  final double pixelRatio;
  final String goldenFolder;
  final ScreenshotFrameBuilder frameBuilder;
}
