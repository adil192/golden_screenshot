// ignore_for_file: deprecated_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  test('Deprecated devices', () {
    expect(GoldenScreenshotDevices.newerIphone, GoldenScreenshotDevices.iphone);
    expect(GoldenScreenshotDevices.olderIphone, GoldenScreenshotDevices.iphone);
    expect(GoldenScreenshotDevices.newerIpad, GoldenScreenshotDevices.ipad);
    expect(GoldenScreenshotDevices.olderIpad, GoldenScreenshotDevices.ipad);
    expect(
      ScreenshotDevices.values,
      GoldenScreenshotDevices.values.map((e) => e.device).toList(),
    );
  });
}
