import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_screenshot/src/fuzzy_comparator.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// An extension on [WidgetTester] that provides some
/// convenience methods for screenshot tests
/// and golden tests in general.
extension ScreenshotTester on WidgetTester {
  /// Prefetches [images] into Flutter's image cache.
  ///
  /// If you don't run this method, images won't load in time
  /// for the screenshot test to capture them.
  ///
  /// This method should only be called after [pumpWidget]
  /// since a widget is needed to provide a [BuildContext]
  /// required to precache the images.
  ///
  /// If you aren't using [ScreenshotApp] somewhere in your widget tree,
  /// you can pass a different [widgetType] to find the widget
  /// that will provide the [BuildContext].
  ///
  /// See also [precacheTopbarImages] which precaches the device frame images.
  Future<void> precacheImages(
    List<ImageProvider> images, {
    Type widgetType = ScreenshotApp,
  }) {
    if (kIsWeb) {
      // This times out with `flutter test --platform chrome`
      return Future.value();
    }
    final context = element(find.byType(widgetType));
    return runAsync(
      () => Future.wait(
        images.map((image) => precacheImage(image, context)),
      ),
    );
  }

  /// Prefetches all [Image]s found in the widget tree.
  ///
  /// This method should only be called after [pumpWidget].
  /// See [precacheImages] for more details.
  Future<void> precacheImagesInWidgetTree({
    bool skipOffstage = true,
    Type widgetType = ScreenshotApp,
  }) {
    final imageWidgets = widgetList<Image>(find.bySubtype<Image>(
      skipOffstage: skipOffstage,
    ));
    final imageProviders = imageWidgets.map((widget) => widget.image).toList();
    return precacheImages(imageProviders, widgetType: widgetType);
  }

  /// Prefetches the top bar images used by [ScreenshotFrame].
  ///
  /// This method should only be called after [pumpWidget].
  /// See [precacheImages] for more details.
  Future<void> precacheTopbarImages({
    Type widgetType = ScreenshotApp,
  }) =>
      precacheImages(
        const [
          ScreenshotFrame.androidTopBarImage,
          ScreenshotFrame.newerIphoneTopBarImage,
          ScreenshotFrame.newerIpadTopBarImage,
          ScreenshotFrame.olderIphoneTopBarImage,
          ScreenshotFrame.olderIpadTopBarImage,
        ],
        widgetType: widgetType,
      );

  /// Flutter uses the `Ahem` font by default in golden tests
  /// which displays a filled rectangle for each character,
  /// which of course isn't suitable for app stores.
  ///
  /// This method loads proper fonts for the app to use in golden tests.
  Future<void> loadFonts() async {
    if (kIsWeb) {
      // This times out with `flutter test --platform chrome`
      return;
    }
    await runAsync(loadAppFonts);
  }

  dynamic get goldenComparator =>
      kIsWeb ? webGoldenComparator : goldenFileComparator;
  set goldenComparator(dynamic value) {
    if (kIsWeb) {
      webGoldenComparator = value;
    } else {
      goldenFileComparator = value;
    }
  }

  /// Uses a [FuzzyComparator] instead of the default golden
  /// file comparator to allow a small amount of difference between
  /// the golden and the test image.
  ///
  /// You may wish to use `tester.expectScreenshot` instead, which already
  /// uses this method.
  void useFuzzyComparator({
    required double allowedDiffPercent,
  }) {
    final previousComparator = goldenComparator;
    addTearDown(() => goldenComparator = previousComparator);

    goldenComparator = FuzzyComparator(
      previousComparator: previousComparator,
      allowedDiffPercent: allowedDiffPercent,
    );
  }

  @Deprecated('Use useFuzzyComparator instead')
  void useScreenshotComparator({
    required double allowedDiffPercent,
  }) =>
      useFuzzyComparator(allowedDiffPercent: allowedDiffPercent);

  /// Use this method instead of the usual [expectLater] to allow
  /// small pixel differences between the golden and the test image.
  ///
  /// By default, this will use the [MaterialApp] widget
  /// (which is a child of the [ScreenshotApp] widget).
  /// If you want to use a different widget, provide a [finder].
  /// Use [goldenFilePath] to override the path to the golden file.
  Future<void> expectScreenshot(
    ScreenshotDevice device,
    String goldenFileName, {
    String? langCode,
    String? goldenFilePath,
    double allowedDiffPercent = 0.1,
    Finder? finder,
  }) async {
    finder ??= find.bySubtype<MaterialApp>();
    useFuzzyComparator(allowedDiffPercent: allowedDiffPercent);
    await expectLater(
      finder,
      device.matchesGoldenFile(goldenFileName, langCode: langCode, goldenFilePath: goldenFilePath),
    );
  }
}
