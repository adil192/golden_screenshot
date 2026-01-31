import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  group('Font weights with', () {
    _testFontWeights(GoldenScreenshotDevices.iphone);
    _testFontWeights(GoldenScreenshotDevices.androidPhone);
  });
}

void _testFontWeights(GoldenScreenshotDevices goldenDevice) {
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
          appBar: AppBar(title: const Text('Font Weight Test')),
          body: Center(
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final fontWeight in FontWeight.values) ...[
                    Text(
                      'Font Weight $fontWeight',
                      style: TextStyle(fontSize: 24, fontWeight: fontWeight),
                    ),
                    Text(
                      'Italic Weight $fontWeight',
                      style: TextStyle(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: fontWeight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.loadAssets();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('font_weight_test_${goldenDevice.name}.png'),
    );
  });
}
