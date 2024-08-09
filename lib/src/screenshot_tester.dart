import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golden_screenshot/src/screenshot_app.dart';

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
          AssetImage('assets/tests/android_topbar.png'),
          AssetImage('assets/tests/newer_iphone_topbar.png'),
          AssetImage('assets/tests/newer_ipad_topbar.png'),
          AssetImage('assets/tests/older_iphone_topbar.png'),
          AssetImage('assets/tests/older_ipad_topbar.png'),
        ],
        widgetType: widgetType,
      );
}
