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

    _screenshot('1_home', home: DemoHomePage());

    _screenshot('2_chat_jane', home: DemoChatPage(userName: 'Jane'));

    _screenshot(
      '3_dialog',
      home: DemoChatPage(userName: 'Jane'),
      beforeScreenshot: (tester) async {
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
  required Widget home,
  Future<void> Function(WidgetTester tester)? beforeScreenshot,
}) {
  group(description, () {
    for (final goldenDevice in GoldenScreenshotDevices.values) {
      testGoldens('for ${goldenDevice.name}', (tester) async {
        final device = goldenDevice.device;

        await tester.pumpWidget(
          ScreenshotApp.withConditionalTitlebar(
            device: device,
            title: 'Talk',
            home: home,
          ),
        );

        // One of our tests needs to interact with the UI before taking the screenshot.
        await beforeScreenshot?.call(tester);

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
