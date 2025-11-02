# golden_screenshot

[![pub.dev](https://img.shields.io/pub/v/golden_screenshot)](https://pub.dev/packages/golden_screenshot)
[![codecov](https://codecov.io/github/adil192/golden_screenshot/graph/badge.svg?token=TIBGLCUE11)](https://codecov.io/github/adil192/golden_screenshot)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/adil192/golden_screenshot/blob/main/LICENSE)

Utilities to automate screenshot generation using Flutter's golden tests.

The generated screenshots are suitable for the App Store, Play Store, F-Droid, Flathub (Linux), etc,
and are saved in a Fastlane-compatible directory structure (e.g. `metadata/en-US/images/phoneScreenshots/1_home.png`) by default.
See [lib/src/screenshot_devices.dart](https://github.com/adil192/golden_screenshot/blob/main/lib/src/screenshot_devices.dart)
for the default list of devices,
or have a look at [Customization](#customization) to customize the devices, frames, and location of the screenshots.

## Getting started

In your `pubspec.yaml` file, add `golden_screenshot` as a `dev_dependency` before running `flutter pub get`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  golden_screenshot: ^x.y.z # Replace x.y.z with the latest version
```

Then create a file in your `test` directory (e.g. `test/screenshot_test.dart`) and use
[demo/test/screenshots_test.dart](https://github.com/adil192/golden_screenshot/blob/main/demo/test/screenshots_test.dart)
as a template to create your own tests.

The main portion might look something like this:

```dart
    _testGame(
      goldenFileName: '1_home',
      child: const HomePage(),
    );
    _testGame(
      gameSave: inProgressGameSave,
      frameColors: playPageFrameColors,
      goldenFileName: '2_play',
      child: const PlayPage(),
    );
    _testGame(
      goldenFileName: '4_shop',
      child: const ShopPage(),
    );
    _testGame(
      goldenFileName: '5_tutorial',
      child: const TutorialPage(),
    );
    _testGame(
      goldenFileName: '6_settings',
      child: const SettingsPage(),
    );
```

If you're familiar with golden tests in Flutter, you'll notice some differences...

We use `testGoldens` instead of `testWidgets` to create the tests, which enables
shadows inside golden files. By default, Flutter disables them since
[shadows are rendered ever-so-slightly differently every time](https://api.flutter.dev/flutter/painting/debugDisableShadows.html),
but we handle this by using a fuzzy comparator.

Additionally, instead of using `expectLater`, we use `tester.expectScreenshot`:

```dart
// OLD
await expectLater(find.byType(HomePage), matchesGoldenFile('path/to/1_home'));
// NEW
await tester.expectScreenshot(device, '1_home');
```

`tester.expectScreenshot` internally enables a fuzzy comparator which allows for
small (0.1% configurable) differences between the expected and actual image,
whereas Flutter typically expects every pixel to be exactly the same.

## Usage

Once you have created your test file, run the following command to generate the screenshots:

```bash
flutter test test/screenshot_test.dart --update-goldens
```

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
    // Your frame implementation
  }
}
```

### Custom screenshot directory

By default, the screenshots are saved in `../metadata/\$localeCode/images/`.
The `../` is because this path is relative to the `test` directory.

You can change this by setting `ScreenshotDevice.screenshotsFolder` to something else. This path should end with a slash too.

```dart
void main() {
  ScreenshotDevice.screenshotsFolder = 'path/to/screenshots/';
  testGoldens('...', (tester) async {
```
