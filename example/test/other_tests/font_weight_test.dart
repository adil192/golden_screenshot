import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  testGoldens('Font weights in goldens', (tester) async {
    await tester.pumpWidget(ScreenshotApp(
      device: GoldenScreenshotDevices.newerIphone.device,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      frameColors: ScreenshotFrameColors.dark,
      home: Scaffold(
        appBar: AppBar(title: const Text('Font Weight Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final fontWeight in FontWeight.values)
                Text(
                  'Font Weight $fontWeight',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: fontWeight,
                  ),
                ),
            ],
          ),
        ),
      ),
    ));

    await tester.precacheImagesInWidgetTree();
    await tester.precacheTopbarImages();
    await tester.loadFonts();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('font_weight_test.png'),
    );
  });
}
