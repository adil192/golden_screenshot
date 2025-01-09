## 3.1.4
- Added goldenFilePath optional parameter to `expectScreenshot` and `matchesGoldenFile` to override path for golden file.

## 3.1.3

- Updated the Android topbar to Android 15

## 3.1.2

- Removed the camera cutout from the iphone top bar

## 3.1.1

- Fixed the color of the new top bars not being set

## 3.1.0

- iOS top bar sizes now match exactly with the real devices.
- Switched newerIphone to the iPhone 16 Pro Max.

## 3.0.2

- Frame colors are now guessed based on the current theme's surface color. This will hopefully be more reliable than the previous `SystemChrome` based implementation.

## 3.0.1

- Added `ScreenshotFrameColors.dark` and `ScreenshotFrameColors.light` named constants for convenience.

## 3.0.0

- The top and bottom bar colors are now decided by Flutter. In most cases, this is sufficient, but you can still override the foreground brightness with by passing a `ScreenshotFrameColors` object to `ScreenshotApp`.

## 2.3.0

- Added localization arguments to `ScreenshotApp`, thanks to @albemala
- Renamed `tester.useScreenshotComparator` to `tester.useFuzzyComparator`

## 2.2.2

- Fixed regression from 2.2.1 where the wrong comparator would be used on io (non-web).

## 2.2.1

- Fixed compilation issues with `flutter test --platform chrome`. However, image/font precaching and fuzzy comparison aren't implemented (yet).

## 2.2.0

- You can now use `tester.useScreenshotComparator` (Update: renamed to `tester.useFuzzyComparator`) without having to use `tester.expectScreenshot`.
- Added a missing `widgetType` option in `precacheImagesInWidgetTree` to allow use without `ScreenshotApp`.

## 2.1.0

- Screenshots now include dialogs with the default finder

## 2.0.1

- Fixed an infinite recursion error in `device.matchesGoldenFile`

## 2.0.0

- Added the ability to use your own set of devices by creating an enum that stores `ScreenshotDevice` objects. See the README for more.
- Added the ability to customize where the goldens are stored by setting `ScreenshotDevice.screenshotsFolder`. See the README for more.
- Added the ability to use multiple locales by passing a locale code to `tester.expectScreenshot`.
- Because of the above, you'll need to make the following changes (see the example for more):
  ```dart
  # OLD
  for (final device in ScreenshotDevice.values) {
    testWidgets('for ${device.name}', (tester) async {
  # NEW
  for (final goldenDevice in GoldenScreenshotDevices.values) {
    testWidgets('for ${goldenDevice.name}', (tester) async {
      final device = goldenDevice.device;
  ```
  ```dart
  # OLD
  await tester.expectScreenshot(matchesGoldenFile(
    '${device.goldenFolder}$goldenFileName.png',
  ));
  # NEW
  await tester.expectScreenshot(device, goldenFileName);
  ```

## 1.5.0

- Made the Linux screenshots 16:9 so they can also be used for the Play Store.

## 1.2.0

- Added a fuzzy comparator to allow for 0.1% difference between a widget's expected and actual image. You should replace the usual `expectLater` with `tester.expectScreenshot(matchesGoldenFile(...))` to use this feature.

## 1.1.0

- You can now run `tester.precacheImagesInWidgetTree()` to precache all images currently in the widget tree, instead of having to manually specify each image with `tester.precacheImages([...])`

## 1.0.2

- Fixed apps that use `MediaQuery.size` not receiving the simulated screen size

## 1.0.1

- Added documentation comments to most of the code

## 1.0.0

- Initial release
