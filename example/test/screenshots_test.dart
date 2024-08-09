/// This file contains the tests that take screenshots of the app.
///
/// Run it with `flutter test --update-goldens` to generate the screenshots
/// or `flutter test` to compare the screenshots to the golden files.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_screenshot_example/main.dart';

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    final homePageTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
    final homePageFrameColors = ScreenshotFrameColors(
      topBar: homePageTheme.colorScheme.inversePrimary,
      bottomBar: homePageTheme.colorScheme.surface,
    );

    _screenshotWidget(
      counter: 100,
      frameColors: homePageFrameColors,
      theme: homePageTheme,
      goldenFileName: '1_counter_100',
      child: const MyHomePage(
        title: 'Golden screenshot demo',
      ),
    );

    _screenshotWidget(
      counter: 998,
      frameColors: homePageFrameColors,
      theme: homePageTheme,
      goldenFileName: '2_counter_998',
      child: const MyHomePage(
        title: 'Golden screenshot demo',
      ),
    );
  });
}

void _screenshotWidget({
  int counter = 0,
  ScreenshotFrameColors? frameColors,
  ThemeData? theme,
  required String goldenFileName,
  required Widget child,
}) {
  group(goldenFileName, () {
    for (final device in ScreenshotDevice.values) {
      testWidgets('for ${device.name}', (tester) async {
        final widget = ScreenshotApp(
          theme: theme,
          device: device,
          frameColors: frameColors,
          child: child,
        );
        await tester.pumpWidget(widget);

        tester.state<MyHomePageState>(find.byType(MyHomePage)).counter =
            counter;

        // You may want to precache images before taking a screenshot
        // but we don't need to in this example.
        // await tester.precacheImages(const [
        //   AssetImage('assets/images/coin.png'),
        // ]);

        // Precache the top bars for each device and the fonts
        // so they're ready for the screenshot.
        await tester.precacheTopbarImages();
        await tester.loadFonts();

        // Pump the widget for a second to ensure animations are complete.
        await tester.pumpFrames(widget, const Duration(seconds: 1));

        // Take the screenshot and compare it to the golden file.
        await expectLater(
          find.byWidget(child),
          matchesGoldenFile('${device.goldenFolder}$goldenFileName.png'),
        );
      });
    }
  });
}
