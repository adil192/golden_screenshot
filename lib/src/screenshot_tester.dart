import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

@internal
const kAllowedDiffPercent = 0.1;

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
  /// ### [alsoLoadTheseFonts]: `null`
  ///
  /// By default, only fonts found in the widget tree are loaded.
  ///
  /// If you use fonts that are not directly referenced in the widget tree,
  /// such as in a CustomPainter, provide them here to ensure they're loaded.
  ///
  /// #### [fontsToMock]: [kFontsToMock]
  ///
  /// If your app's text theme uses a font which isn't bundled with your app,
  /// it'll fall back to `Ahem`
  /// (regardless of any [TextStyle.fontFamilyFallback]s).
  /// In that case, you need to provide the list of such fonts like this:
  /// ```dart
  ///   fontsToMock: ['Comic Sans', ...kFontsToMock],
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
  Future<void> loadAssets({
    Iterable<String>? alsoLoadTheseFonts,
    Iterable<String> fontsToMock = kFontsToMock,
    @Deprecated('This was renamed to fontsToMock')
    Iterable<String> overriddenFonts = const [],
    bool searchWidgetTreeForImages = true,
    bool skipOffstageImages = true,
    List<ImageProvider>? imagesToInclude,
    @Deprecated('No longer needed, context is found automatically')
    Type? widgetType,
  }) => runAsync(
    () => Future.wait([
      _findAndLoadFonts(
        alsoLoadTheseFonts: alsoLoadTheseFonts,
        fontsToMock: kFontsToMock,
        // ignore: deprecated_member_use_from_same_package
        overriddenFonts: overriddenFonts,
      ),
      _findAndLoadImages(
        searchWidgetTree: searchWidgetTreeForImages,
        skipOffstage: skipOffstageImages,
        imagesToInclude: imagesToInclude,
      ),
    ]),
  );

  /// Finds all the [Image]s in the widget tree and loads them into the image
  /// cache.
  ///
  /// See [loadAssets] for the parameters.
  Future<void> _findAndLoadImages({
    bool searchWidgetTree = true,
    bool skipOffstage = true,
    List<ImageProvider>? imagesToInclude,
    @Deprecated('No longer needed, context is found automatically')
    Type? widgetType,
  }) {
    if (kIsWeb) {
      // This times out with `flutter test --platform chrome`
      return Future.value();
    }

    final imageWidgets = searchWidgetTree
        ? widgetList<Image>(find.bySubtype<Image>(skipOffstage: skipOffstage))
        : const <Image>[];
    final imageProviders = [
      ...imageWidgets.map((widget) => widget.image),
      ...?imagesToInclude,
    ];
    if (imageProviders.isEmpty) {
      return Future.value();
    }

    final context = binding.rootElement!;
    return Future.wait(
      imageProviders.map((image) => precacheImage(image, context)),
    );
  }

  /// Finds all fonts used in the widget tree and loads them.
  ///
  /// See [loadAssets] for the parameters.
  Future<void> _findAndLoadFonts({
    Iterable<String>? alsoLoadTheseFonts,
    Iterable<String> fontsToMock = kFontsToMock,
    @Deprecated('This was renamed to fontsToMock')
    Iterable<String> overriddenFonts = const [],
  }) {
    if (kIsWeb) {
      // rootBundle not available on web
      // https://github.com/flutter/flutter/issues/159879
      return Future.value();
    }

    final onlyLoadTheseFonts = alsoLoadTheseFonts?.toSet() ?? <String>{};

    for (final paragraph in renderObjectList<RenderParagraph>(
      find.bySubtype<RichText>(), // includes [Text] as well
    )) {
      final strutStyleFont = paragraph.strutStyle?.fontFamily;
      if (strutStyleFont != null) onlyLoadTheseFonts.add(strutStyleFont);
      final textStyleFont = paragraph.text.style?.fontFamily;
      if (textStyleFont != null) onlyLoadTheseFonts.add(textStyleFont);
    }
    for (final widget in widgetList<DefaultTextStyle>(
      find.bySubtype<DefaultTextStyle>(),
    )) {
      final fontFamily = widget.style.fontFamily;
      if (fontFamily != null) onlyLoadTheseFonts.add(fontFamily);
    }
    for (final widget in widgetList<Theme>(find.bySubtype<Theme>())) {
      final textTheme = widget.data.textTheme;
      for (final textStyle in textTheme.styles) {
        final fontFamily = textStyle.fontFamily;
        if (fontFamily != null) onlyLoadTheseFonts.add(fontFamily);
      }
    }

    return loadAppFonts(
      onlyLoadTheseFonts: onlyLoadTheseFonts,
      fontsToMock: fontsToMock,
      // ignore: deprecated_member_use_from_same_package
      overriddenFonts: overriddenFonts,
    );
  }

  /// Uses a [FuzzyComparator] instead of the default golden
  /// file comparator to allow a small amount of difference between
  /// the golden and the test image.
  ///
  /// You most likely do not need to call this method directly.
  /// It's called automatically by [testGoldens].
  void useFuzzyComparator({double allowedDiffPercent = kAllowedDiffPercent}) {
    // We can't yet use FuzzyComparator on the web
    if (kIsWeb) return;
    // No need to use a fuzzy comparator if the allowed difference is zero
    if (allowedDiffPercent <= 0) return;

    final previousComparator = goldenFileComparator;
    if (previousComparator is! FuzzyComparator) {
      addTearDown(() => goldenFileComparator = previousComparator);
    }

    goldenFileComparator = FuzzyComparator(
      previousComparator: previousComparator,
      allowedDiffPercent: allowedDiffPercent,
    );
  }

  /// Takes a screenshot and compares it to a golden file.
  /// The golden file's path is determined by the [ScreenshotDevice].
  ///
  /// By default, this will use the [MaterialApp] widget
  /// (which is a child of the [ScreenshotApp] widget).
  /// If you want to use a different widget, provide a [finder].
  Future<void> expectScreenshot(
    ScreenshotDevice device,
    String goldenFileName, {
    String? langCode,
    @Deprecated(
      'Use `allowedDiffPercent` in `testGoldens()` instead. '
      '`expectScreenshot` no longer sets the comparator.',
    )
    double allowedDiffPercent = kAllowedDiffPercent,
    Finder? finder,
  }) async {
    finder ??= find.byType(MaterialApp);
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
    double allowedDiffPercent = kAllowedDiffPercent,
  }) => useFuzzyComparator(allowedDiffPercent: allowedDiffPercent);

  @Deprecated(
    'Use `loadAssets()` instead, '
    'which loads all needed images and fonts in one call.',
  )
  Future<void> precacheImages(
    List<ImageProvider> images, {
    @Deprecated('No longer needed, context is found automatically')
    Type? widgetType,
  }) => runAsync(
    () => _findAndLoadImages(
      searchWidgetTree: false,
      widgetType: widgetType,
      imagesToInclude: images,
    ),
  );

  @Deprecated(
    'Use `loadAssets()` instead, '
    'which loads all needed images and fonts in one call.',
  )
  Future<void> precacheImagesInWidgetTree({
    bool skipOffstage = true,
    @Deprecated('No longer needed, context is found automatically')
    Type? widgetType,
  }) => runAsync(
    () =>
        _findAndLoadImages(skipOffstage: skipOffstage, widgetType: widgetType),
  );

  @Deprecated(
    'Use `loadAssets()` instead, '
    'which loads all needed images and fonts in one call.',
  )
  Future<void> precacheTopbarImages({
    @Deprecated('No longer needed, context is found automatically')
    Type? widgetType,
  }) => runAsync(
    () => _findAndLoadImages(
      searchWidgetTree: false,
      widgetType: widgetType,
      imagesToInclude: const [
        ScreenshotFrame.androidPhoneTopBarImage,
        ScreenshotFrame.androidTabletTopBarImage,
        ScreenshotFrame.iphoneTopBarImage,
        ScreenshotFrame.ipadTopBarImage,
      ],
    ),
  );

  @Deprecated(
    'Use `loadAssets()` instead, '
    'which loads all needed images and fonts in one call.',
  )
  Future<void> loadFonts({
    Iterable<String> fontsToMock = kFontsToMock,
    @Deprecated('This was renamed to fontsToMock')
    Iterable<String> overriddenFonts = const [],
  }) => runAsync(
    () => loadAppFonts(
      fontsToMock: kFontsToMock,
      overriddenFonts: overriddenFonts,
    ),
  );
}

extension _IterableTextTheme on TextTheme {
  Iterable<TextStyle> get styles => [
    ?displayLarge,
    ?displayMedium,
    ?displaySmall,
    ?headlineLarge,
    ?headlineMedium,
    ?headlineSmall,
    ?titleLarge,
    ?titleMedium,
    ?titleSmall,
    ?bodyLarge,
    ?bodyMedium,
    ?bodySmall,
    ?labelLarge,
    ?labelMedium,
    ?labelSmall,
  ];
}
