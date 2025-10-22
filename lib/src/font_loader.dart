import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef JsonMap = Map<String, dynamic>;

/// {@template loadAppFonts}
/// Flutter uses the `Ahem` font by default in golden tests
/// which displays a filled rectangle for each character,
/// which of course isn't suitable for app stores.
///
/// This method loads proper fonts for the app to use in golden tests.
///
/// Note that if your app specifies a custom font (e.g. Comic Sans)
/// with font fallbacks, but does not include said custom font,
/// the font fallbacks will not be applied. Ahem will be used instead.
/// In this case, please provide the [overriddenFonts] parameter like this
/// with the fonts that should be forced to use Roboto instead of Ahem:
/// {@endtemplate}
///
/// ```dart
/// await loadAppFonts(overriddenFonts: ['Comic Sans', ...kOverriddenFonts]);
/// ```
Future<void> loadAppFonts({
  List<String> overriddenFonts = kOverriddenFonts,
}) async {
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

/// The fonts overridden by Roboto in [loadAppFonts].
///
/// This list represents the default fonts used by Flutter on various platforms.
const kOverriddenFonts = [
  // Android
  'Inter',
  'Roboto',

  // Linux
  'Adwaita Sans',
  'Cantarell',
  'Noto Sans',
  'Ubuntu',
  'packages/yaru/Ubuntu',

  // Windows
  'Segoe UI',

  // Apple
  'CupertinoSystemDisplay',
  'CupertinoSystemText',
  '.AppleSystemUIFont',
  '.SF Pro Display',
  '.SF Pro Text',
  '.SF UI Display',
  '.SF UI Text',

  // Other
  'system-ui',
  'sans-serif',
];
