import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  testGoldens('Font weights in goldens', (tester) async {
    await tester.pumpWidget(ScreenshotApp(
      device: GoldenScreenshotDevices.newerIphone.device,
      child: FontWeightTestApp(),
    ));

    await tester.precacheImagesInWidgetTree();
    await tester.precacheTopbarImages();
    await tester.loadFonts();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FontWeightTestApp),
      matchesGoldenFile('font_weight_test.png'),
    );
  });
}

class FontWeightTestApp extends StatelessWidget {
  const FontWeightTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
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
    );
  }
}
