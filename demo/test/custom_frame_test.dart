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

    await tester.loadAssets();
    await tester.pump();

    tester.useFuzzyComparator();
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
        child: Stack(
          fit: StackFit.expand,
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
            Positioned(
              top: 210,
              left: 8,
              right: 8,
              child: FittedBox(
                child: Container(
                  width: device.resolution.width / device.pixelRatio,
                  height: device.resolution.height / device.pixelRatio,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(64),
                  ),
                  foregroundDecoration: BoxDecoration(
                    border: Border.all(width: 8),
                    borderRadius: BorderRadius.circular(64),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ScreenshotFrame.iphone(device: device, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
