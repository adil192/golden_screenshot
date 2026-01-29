import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  group('Font scripts with', () {
    _testFontScripts(GoldenScreenshotDevices.iphone);
    _testFontScripts(GoldenScreenshotDevices.androidPhone);
  });
}

final _greetings = '''
English: Good morning!
Amharic: ምልካም እድል!
Arabic: صباح الخير!
Armenian: Բարի լույս։
Gujrati: સુપ્રભાત!
Greek: Καλημέρα!
Hebrew: בוקר טוב!
Russian: Доброе утро!
Thai: สวัสดีตอนเช้า!
''';

void _testFontScripts(GoldenScreenshotDevices goldenDevice) {
  testGoldens(goldenDevice.name, (tester) async {
    await tester.pumpWidget(
      ScreenshotApp(
        device: goldenDevice.device,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          platform: goldenDevice.device.platform,
        ),
        frameColors: ScreenshotFrameColors.dark,
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                for (final fontWeight in [
                  FontWeight.w200,
                  FontWeight.w400,
                  FontWeight.w600,
                  FontWeight.w800,
                ])
                  Text(
                    _greetings,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: fontWeight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.loadAssets();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('font_script_test_${goldenDevice.name}.png'),
    );
  });
}
