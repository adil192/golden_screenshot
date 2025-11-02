# golden_screenshot

Easily generate screenshots
<span aria-hidden="true">like this</span>
for all app stores:

<p align="middle" aria-hidden="true"><img width="76%" align="middle" src="https://raw.githubusercontent.com/adil192/golden_screenshot/main/demo/metadata/en-US/images/flathubScreenshots/2_chat_jane.png"><img width="23%" align="middle" src="https://raw.githubusercontent.com/adil192/golden_screenshot/main/demo/metadata/en-US/images/phoneScreenshots/2_chat_jane.png"></p>

[![pub.dev](https://img.shields.io/pub/v/golden_screenshot)](https://pub.dev/packages/golden_screenshot)
[![codecov](https://codecov.io/github/adil192/golden_screenshot/graph/badge.svg?token=TIBGLCUE11)](https://codecov.io/github/adil192/golden_screenshot)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/adil192/golden_screenshot/blob/main/LICENSE)

This package makes it easy to generate screenshots of your Flutter app for 
the App Store, Play Store, F-Droid, Flathub (Linux), etc.<br>
You can use the provided set of common devices (phones, tablets, desktops)
or create your own custom devices and frames.

This package is also great for regular golden tests, not just for app store screenshots. It provides lots of flexibility and functionality beyond what Flutter has built-in.

## Getting started

Add `golden_screenshot` to your app as a dev dependency:

```bash
flutter pub add dev:golden_screenshot
```

Then create a file in your `test` directory (e.g. `test/screenshot_test.dart`).
In that file, you will create tests that load widgets and take screenshots of them.
Please use [the example test file](https://github.com/adil192/golden_screenshot/blob/main/demo/test/screenshots_test.dart) as a starting point. <br/>
If you're new to golden testing, watching a tutorial on Flutter golden testing will help you understand the basics.

Once you have your test file, you can run the tests to generate the screenshots:

```bash
flutter test --update-goldens
```

That's it! Your screenshots will be generated in the appropriate directories.

## Differences from regular golden tests

If you're familiar with golden tests in Flutter, you'll notice 2 small differences...

We use `testGoldens` instead of `testWidgets` to create the tests, which is a convenience function to enable shadows inside golden tests. By default, Flutter renders them as solid black borders to
[avoid flakiness](https://api.flutter.dev/flutter/rendering/debugDisableShadows.html), but we handle this by using a fuzzy comparator.

Additionally, instead of using `expectLater`, we use `tester.expectScreenshot`:

```dart
// OLD
await expectLater(find.byType(MaterialApp), matchesGoldenFile('metadata/en-US/images/phoneScreenshots/1_home.png'));
// NEW
await tester.expectScreenshot(device, '1_home');
```

`tester.expectScreenshot` gives us two benefits:
- It automatically determines the golden file path.
- It enables a fuzzy comparator. Flutter's default behavior is to expect pixel-perfect matches in golden tests, but for our purposes, we can allow a small (0.1% configurable) mismatch without issue.

## Usage with regular golden tests

You can also use this package for regular golden tests, not just for app store screenshots. Just make a few adjustments to your existing golden tests:
- Use `testGoldens` instead of `testWidgets`.
- Use a `ScreenshotApp` to get a realistic device frame:
  ```dart
  final app = ScreenshotApp(
    device: GoldenScreenshotDevices.iphone.device,
    child: MyApp(),
  );
  await tester.pumpWidget(app);
  ```
- Before the `matchesGoldenFile` line, call these methods:
  ```dart
  await tester.precacheImagesInWidgetTree();
  await tester.loadFonts();
  await tester.pump();

  tester.useFuzzyComparator();
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(...));
  ```

## Other notes

- Always use `find.byType(MaterialApp)` not `find.byType(MyWidget)` when taking screenshots, so that the device frame is included in the golden image.
- `tester.loadFonts()` will replace any missing fonts with Roboto. If you wish to avoid this, ensure all font files you need are bundled with your app.
- If your golden images don't need to be high-resolution, you can swap `GoldenScreenshotDevices` with `GoldenSmallDevices` which have smaller resolutions to speed up tests.

## Customization

### Custom devices

If you don't want to use the default set of devices (`GoldenScreenshotDevices`),
you can create your own set of devices by creating an enum containing
`ScreenshotDevice` instances.
See [GoldenScreenshotDevices](https://github.com/adil192/golden_screenshot/blob/main/lib/src/screenshot_devices.dart) for what your enum should look like.

```dart
enum MyScreenshotDevices {
  phone(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(1440, 3120),
    pixelRatio: 10 / 3,
    goldenSubFolder: 'phoneScreenshots/',
    frameBuilder: ScreenshotFrame.android,
  )),
  tablet(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(2732, 2048),
    pixelRatio: 2,
    goldenSubFolder: 'tenInchScreenshots/',
    frameBuilder: MyTabletFrame.new,
  ));

  const GoldenScreenshotDevices(this.device);
  final ScreenshotDevice device;
}
```

### Custom frames

You can create your own frames by creating a widget whose contructor
has the same signature as `ScreenshotFrame`'s constructor,
i.e. has the type `ScreenshotFrameBuilder`.

You can then pass your frame's constructor to the `ScreenshotDevice`'s `frameBuilder` parameter as above.

```dart
class MyTabletFrame extends StatelessWidget {
  const MyTabletFrame({
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
    // Your frame implementation, e.g. add system UIs, borders, etc.
  }
}
```

### Custom screenshot directory

By default, the screenshots are saved in `../metadata/\$localeCode/images/`.
The `../` is because this path is relative to your current test file.

You can change this by setting `ScreenshotDevice.screenshotsFolder` to something else. This path should end with a slash too.

```dart
void main() {
  ScreenshotDevice.screenshotsFolder = 'path/to/screenshots/';
  testGoldens('...', (tester) async {
```
