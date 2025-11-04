import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_screenshot_demo/main.dart';

void main() {
  testGoldens('Custom frame', (tester) async {
    final device = ScreenshotDevice(
      platform: TargetPlatform.iOS,
      resolution: Size(1320, 2868),
      pixelRatio: 3,
      goldenSubFolder: 'iphoneScreenshots/',
      frameBuilder: CustomFrame.new,
    );

    await tester.pumpWidget(
      ScreenshotApp(device: device, home: DemoHomePage()),
    );

    await tester.precacheImagesInWidgetTree();
    await tester.loadFonts();
    await tester.pump();

    tester.useFuzzyComparator(allowedDiffPercent: 0.1);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('custom_frame_test.png'),
    );
  });
}

class CustomFrame extends StatelessWidget {
  const CustomFrame({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  });

  final ScreenshotDevice device;
  final ScreenshotFrameColors? frameColors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 8),
              child: Text(
                'Talk to your friends\n in style!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(64),
                    topRight: Radius.circular(64),
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 8),
                    left: BorderSide(color: Colors.black, width: 8),
                    right: BorderSide(color: Colors.black, width: 8),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(64),
                    topRight: Radius.circular(64),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ScreenshotFrame.iphone(device: device, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
