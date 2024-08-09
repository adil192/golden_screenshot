import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

extension ScreenshotTester on WidgetTester {
  Future<void> precacheImages(
    List<ImageProvider> images, {
    Type widgetType = ScreenshotApp,
  }) {
    final context = element(find.byType(widgetType));
    return runAsync(
      () => Future.wait(
        images.map((image) => precacheImage(image, context)),
      ),
    );
  }

  Future<void> precacheTopbarImages({
    Type widgetType = ScreenshotApp,
  }) =>
      precacheImages(
        const [
          ScreenshotFrame.androidTopBarImage,
          ScreenshotFrame.newerIphoneTopBarImage,
          ScreenshotFrame.newerIpadTopBarImage,
          ScreenshotFrame.olderIphoneTopBarImage,
          ScreenshotFrame.olderIpadTopBarImage,
        ],
        widgetType: widgetType,
      );

  Future<void> loadFonts() async => await runAsync(loadAppFonts);
}
