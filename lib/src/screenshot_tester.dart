import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

const _kAllowedDiffPercent = 0.1;

/// An extension on [WidgetTester] that provides some
/// convenience methods for screenshot tests
/// and golden tests in general.
extension ScreenshotTester on WidgetTester {
  /// Loads the images and fonts required by the current widget tree.
  /// You should call this method after [pumpWidget] and before the golden
  /// comparison.
  /// In most cases, you do not need to pass any parameters to this method.
  ///
  /// ### Why is this needed?
  ///
  /// By default, Flutter uses the `Ahem` font in tests which renders each
  /// character as a filled rectangle (not readable text).
  /// Additionally, images used in the widget tree take a few moments to load,
  /// and if left alone, won't be loaded in time for the golden comparison.
  ///
  /// In short, you need to load your fonts and images!
  ///
  /// ### Parameters
  ///
  /// All of these parameters are optional and usually not needed...
  ///
  /// #### [overriddenFonts]: [kOverriddenFonts]
  ///
  /// If your app's text theme uses a font which isn't bundled with your app,
  /// it'll fall back to `Ahem`
  /// (regardless of any [TextStyle.fontFamilyFallback]s).
  /// In that case, you need to provide the list of such fonts like this:
  /// ```dart
  ///   overriddenFonts: ['Comic Sans', ...kOverriddenFonts],
  /// ```
  ///
  /// #### [searchWidgetTreeForImages]: `true`
  ///
  /// Set this to false to skip searching the widget tree for images.
  /// You must then manually provide [imagesToInclude] if you want to load
  /// any images.
  ///
  /// #### [skipOffstageImages]: `true`
  ///
  /// When searching the widget tree for images, offscreen images are skipped
  /// since they are not visible anyway.
  /// Set this to false to include offscreen images as well.
  ///
  /// #### [imagesToInclude]: `null`
  ///
  /// A list of images to include in addition to any found in the widget tree,
  /// e.g.:
  /// ```dart
  ///  imagesToInclude: [AssetImage('assets/logo.png')],
  /// ```
  ///
  /// #### [widgetType]: [ScreenshotApp]
  ///
  /// Flutter's [precacheImage] method requires a [BuildContext].
  /// For this, we get the context from a widget of this type.
  /// Specify a different type if you aren't using [ScreenshotApp].
  Future<void> loadAssets({
    Iterable<String> overriddenFonts = kOverriddenFonts,
    bool searchWidgetTreeForImages = true,
    bool skipOffstageImages = true,
    List<ImageProvider>? imagesToInclude,
    Type widgetType = ScreenshotApp,
  }) =>
      runAsync(() => Future.wait([
            loadAppFonts(overriddenFonts: overriddenFonts),
            _loadImages(
              searchWidgetTree: searchWidgetTreeForImages,
              skipOffstage: skipOffstageImages,
              imagesToInclude: imagesToInclude,
              widgetType: widgetType,
            ),
          ]));

  /// Finds all the [Image]s in the widget tree and loads them into the image
  /// cache.
  ///
  /// See [loadAssets] for the parameters.
  Future<void> _loadImages({
    bool searchWidgetTree = true,
    bool skipOffstage = true,
    Type widgetType = ScreenshotApp,
    List<ImageProvider>? imagesToInclude,
  }) {
    if (kIsWeb) {
      // This times out with `flutter test --platform chrome`
      return Future.value();
    }

    final context = element(find.byType(widgetType));

    final imageWidgets = searchWidgetTree
        ? widgetList<Image>(find.bySubtype<Image>(skipOffstage: skipOffstage))
        : const <Image>[];
    final imageProviders = [
      ...imageWidgets.map((widget) => widget.image),
      ...?imagesToInclude,
    ];

    return Future.wait(
      imageProviders.map((image) => precacheImage(image, context)),
    );
  }

  /// Uses a [FuzzyComparator] instead of the default golden
  /// file comparator to allow a small amount of difference between
  /// the golden and the test image.
  ///
  /// You may wish to use `tester.expectScreenshot` instead, which already
  /// uses this method.
  void useFuzzyComparator({
    double allowedDiffPercent = _kAllowedDiffPercent,
  }) {
    if (kIsWeb) {
      // We can't yet use FuzzyComparator on the web
      return;
    }

    final previousComparator = goldenFileComparator;
    if (previousComparator is! FuzzyComparator) {
      addTearDown(() => goldenFileComparator = previousComparator);
    }

    goldenFileComparator = FuzzyComparator(
      previousComparator: previousComparator,
      allowedDiffPercent: allowedDiffPercent,
    );
  }

  /// Use this method instead of the usual [expectLater] to allow
  /// small pixel differences between the golden and the test image.
  ///
  /// By default, this will use the [MaterialApp] widget
  /// (which is a child of the [ScreenshotApp] widget).
  /// If you want to use a different widget, provide a [finder].
  Future<void> expectScreenshot(
    ScreenshotDevice device,
    String goldenFileName, {
    String? langCode,
    double allowedDiffPercent = _kAllowedDiffPercent,
    Finder? finder,
  }) async {
    finder ??= find.byType(MaterialApp);
    useFuzzyComparator(allowedDiffPercent: allowedDiffPercent);
    await expectLater(
      finder,
      device.matchesGoldenFile(goldenFileName, langCode: langCode),
    );
  }

  // ========================= //
  //                           //
  // Deprecated methods below. //
  //                           //
  // ========================= //

  @Deprecated('Use useFuzzyComparator instead')
  void useScreenshotComparator({
    double allowedDiffPercent = _kAllowedDiffPercent,
  }) =>
      useFuzzyComparator(allowedDiffPercent: allowedDiffPercent);

  @Deprecated('Use `loadAssets()` instead, '
      'which loads all needed images and fonts in one call.')
  Future<void> precacheImages(
    List<ImageProvider> images, {
    Type widgetType = ScreenshotApp,
  }) =>
      runAsync(() => _loadImages(
            searchWidgetTree: false,
            widgetType: widgetType,
            imagesToInclude: images,
          ));

  @Deprecated('Use `loadAssets()` instead, '
      'which loads all needed images and fonts in one call.')
  Future<void> precacheImagesInWidgetTree({
    bool skipOffstage = true,
    Type widgetType = ScreenshotApp,
  }) =>
      runAsync(() => _loadImages(
            skipOffstage: skipOffstage,
            widgetType: widgetType,
          ));

  @Deprecated('Use `loadAssets()` instead, '
      'which loads all needed images and fonts in one call.')
  Future<void> precacheTopbarImages({
    Type widgetType = ScreenshotApp,
  }) =>
      runAsync(() => _loadImages(
            searchWidgetTree: false,
            widgetType: widgetType,
            imagesToInclude: const [
              ScreenshotFrame.androidPhoneTopBarImage,
              ScreenshotFrame.androidTabletTopBarImage,
              ScreenshotFrame.iphoneTopBarImage,
              ScreenshotFrame.ipadTopBarImage,
            ],
          ));

  @Deprecated('Use `loadAssets()` instead, '
      'which loads all needed images and fonts in one call.')
  Future<void> loadFonts({
    Iterable<String> overriddenFonts = kOverriddenFonts,
  }) =>
      runAsync(() => loadAppFonts(overriddenFonts: overriddenFonts));
}
