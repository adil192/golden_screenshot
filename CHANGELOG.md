## 1.3.0

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
