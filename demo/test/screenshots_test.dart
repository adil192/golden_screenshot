/// This file contains the tests that take screenshots of the app.
///
/// Run it with `flutter test --update-goldens` to generate the screenshots
/// or `flutter test` to compare the screenshots to the golden files.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_screenshot_demo/main.dart';

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    _screenshot(
      '1_home',
      pumpApp: (tester, device) async {
        final app = ScreenshotApp.withConditionalTitlebar(
          device: device,
          title: 'Talk',
          home: DemoHomePage(),
        );
        await tester.pumpWidget(app);
      },
    );

    _screenshot(
      '2_chat_jane',
      pumpApp: (tester, device) async {
        final app = ScreenshotApp.withConditionalTitlebar(
          device: device,
          title: 'Talk',
          home: DemoChatPage(userName: 'Jane'),
        );
        await tester.pumpWidget(app);
      },
    );

    _screenshot(
      '3_dialog',
      pumpApp: (tester, device) async {
        final app = ScreenshotApp.withConditionalTitlebar(
          device: device,
          title: 'Talk',
          home: DemoChatPage(userName: 'Jane'),
        );
        await tester.pumpWidget(app);

        await tester.enterText(find.byType(TextField), 'Hello Jane!');
        await tester.pump();
        await tester.longPress(find.byIcon(Icons.send));
        await tester.pump();
      },
    );
  });
}

void _screenshot(
  String description, {
  required Future<void> Function(WidgetTester, ScreenshotDevice) pumpApp,
}) {
  group(description, () {
    for (final goldenDevice in GoldenScreenshotDevices.values) {
      testGoldens('for ${goldenDevice.name}', (tester) async {
        final device = goldenDevice.device;

        await pumpApp(tester, device);

        // Precache the images and fonts so they're ready for the screenshot.
        await tester.loadAssets();

        // Pump the widget for a second to ensure animations are complete.
        await tester.pumpFrames(
          tester.widget(find.byType(ScreenshotApp)),
          const Duration(seconds: 1),
        );

        // Take the screenshot and compare it to the golden file.
        await tester.expectScreenshot(device, description);
      });
    }
  });
}
