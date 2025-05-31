import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef JsonMap = Map<String, dynamic>;

/// By default, flutter golden tests show the Ahem font consisting of black
/// rectangles for each character.
///
/// Call this method in your tests to change that behavior.
/// It will load the fonts provided by your app and its dependencies,
/// including the Roboto font provided by this package.
Future<void> loadAppFonts() async {
  if (kIsWeb) {
    // rootBundle not available on web
    // https://github.com/flutter/flutter/issues/159879
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  /// See [assets/reference/FontManifest.jsonc] for an example FontManifest.json
  final fontManifest = await rootBundle.loadStructuredData(
    'FontManifest.json',
    (json) async => jsonDecode(json) as List,
  );

  /// The `packages/golden_screenshot/Roboto` family from this package,
  /// which we'll use to override [overriddenFonts].
  JsonMap? robotoFontObject;
  const robotoFamilyWithPackage = 'packages/golden_screenshot/Roboto';

  final fontLoadingFutures = <Future<void>>[];
  for (final JsonMap fontObject in fontManifest) {
    final family = fontObject['family'] as String;
    fontLoadingFutures.add(loadFont(family, fontObject));
    if (family == robotoFamilyWithPackage) robotoFontObject = fontObject;
  }

  if (robotoFontObject != null) {
    // Now override [overriddenFonts] with our Roboto font
    for (final family in overriddenFonts) {
      fontLoadingFutures.add(loadFont(family, robotoFontObject));
    }
  } else {
    debugPrint(
      'Warning: The Roboto font provided by golden_screenshot '
      'could not be found in the FontManifest.json.\n'
      'This is likely a bug in golden_screenshot, please file an issue at '
      'https://github.com/adil192/golden_screenshot/issues',
    );
  }

  await Future.wait(fontLoadingFutures);
}

Future<void> loadFont(String family, JsonMap fontObject) {
  final fontLoader = FontLoader(family);
  for (final JsonMap fontDef in fontObject['fonts'] as List) {
    final assetPath = fontDef['asset'] as String;
    final assetBytesFuture = rootBundle.load(assetPath);
    fontLoader.addFont(assetBytesFuture);
  }
  return fontLoader.load();
}

const kOverriddenFonts = [
  'Roboto',
  '.SF UI Display',
  '.SF UI Text',
  '.SF Pro Text',
  '.SF Pro Display',
];
