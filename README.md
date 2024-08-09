# golden_screenshot

Utilities to automate screenshot generation using Flutter's golden tests.

Currently, there isn't much customization available, but I'll probably add more in the future.

The generated screenshots are suitable for the App Store, Play Store, F-Droid, Flathub (Linux), etc,
and are saved in a Fastlane-compatible directory structure (e.g. `metadata/en-US/images/phoneScreenshots/1_home.png`).
See [lib/src/screenshot_device.dart](https://github.com/adil192/golden_screenshot/blob/main/lib/src/screenshot_device.dart)
for the list of devices and the paths where the screenshots are saved.

## Getting started

In your `pubspec.yaml` file, add `golden_screenshot` as a `dev_dependency` before running `flutter pub get`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  golden_screenshot: ^x.y.z # Replace x.y.z with the latest version
```

Then create a file in your `test` directory (e.g. `test/screenshot_test.dart`) and use
[example/test/screenshots_test.dart](https://github.com/adil192/golden_screenshot/blob/main/example/test/screenshots_test.dart)
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

## Usage

Once you have created your test file, run the following command to generate the screenshots:

```bash
flutter test test/screenshot_test.dart --update-goldens
```
