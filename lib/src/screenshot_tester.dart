import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
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
    final context = element(find.byType(widgetType));
    return runAsync(
      () => Future.wait(
        images.map((image) => precacheImage(image, context)),
      ),
    );
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
  Future<void> loadFonts() async => await runAsync(loadAppFonts);
}
