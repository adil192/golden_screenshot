import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  testGoldens('some test', (tester) async {
    final app = ScreenshotApp(
      device: GoldenScreenshotDevices.newerIphone.device,
      child: Text('child renamed to home'),
    );
    print(app.child);
  });
}
