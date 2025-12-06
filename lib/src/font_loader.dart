import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/src/apple_fonts.dart';
import 'package:golden_screenshot/src/roboto_fonts.dart';

typedef JsonMap = Map<String, dynamic>;

/// Flutter uses the `Ahem` font by default in golden tests
/// which displays a filled rectangle for each character,
/// which of course isn't suitable for app stores.
///
/// This method loads proper fonts for the app to use in golden tests.
///
/// Note that if your app specifies a custom font (e.g. Comic Sans)
/// with font fallbacks, but does not include said custom font,
/// the font fallbacks will not be applied. Ahem will be used instead.
/// In this case, please provide the [fontsToReplaceWithRoboto] parameter
/// with the fonts that should be forced to use Roboto instead of Ahem, e.g.:
///
/// ```dart
/// await loadAppFonts(fontsToReplaceWithRoboto: ['Comic Sans', ...kFontsToReplaceWithRoboto]);
/// ```
Future<void> loadAppFonts({
  Iterable<String> fontsToReplaceWithRoboto = kFontsToReplaceWithRoboto,
  @Deprecated('This was renamed to fontsToReplaceWithRoboto')
  Iterable<String> overriddenFonts = const [],
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

  final fontLoadingFutures = <Future<void>>[];
  for (final JsonMap fontObject in fontManifest) {
    final family = fontObject['family'] as String;
    if (family == RobotoFonts.familyWithPackage) continue;
    fontLoadingFutures.add(loadFontAsset(family, fontObject));
  }
  await for (final (:family, :fonts) in AppleFonts.getFontFamilies()) {
    fontLoadingFutures.add(loadFontFiles(family, fonts));
  }

  // Now override [fontsToReplaceWithRoboto]
  for (final family in Set.from(fontsToReplaceWithRoboto)
    ..addAll(overriddenFonts)) {
    if (_appleFontFamilies.contains(family) && AppleFonts.available) {
      // Apple fonts are available, no need to override them with Roboto
      continue;
    }
    fontLoadingFutures.add(loadRoboto(family));
  }

  await Future.wait(fontLoadingFutures);
}

Future<void> loadFontAsset(String family, JsonMap fontObject) {
  final fontLoader = FontLoader(family);
  for (final JsonMap fontDef in fontObject['fonts'] as List) {
    final assetPath = fontDef['asset'] as String;
    final assetBytesFuture = rootBundle.load(assetPath);
    fontLoader.addFont(assetBytesFuture);
  }
  return fontLoader.load();
}

/// Different to [loadFontAsset] because we don't want to read the asset
/// into memory multiple times. [RobotoFonts.assetFutures] is only created once.
Future<void> loadRoboto([String family = RobotoFonts.familyWithPackage]) async {
  final fontLoader = FontLoader(family);
  for (final assetBytesFuture in RobotoFonts.assetFutures) {
    fontLoader.addFont(assetBytesFuture);
  }
  return fontLoader.load();
}

Future<void> loadFontFiles(String family, List<Uint8List> files) {
  final fontLoader = FontLoader(family);
  for (final file in files) {
    final assetBytesFuture = Future.value(ByteData.view(file.buffer));
    fontLoader.addFont(assetBytesFuture);
  }
  return fontLoader.load();
}

/// The fonts overridden by Roboto in [loadAppFonts].
///
/// This list represents the default fonts used by Flutter on various platforms.
const kFontsToReplaceWithRoboto = {
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
  ..._appleFontFamilies,

  // Other
  'system-ui',
  'sans-serif',
};

const _appleFontFamilies = [
  'CupertinoSystemDisplay',
  'CupertinoSystemText',
  '.AppleSystemUIFont',
  '.SF Pro Display',
  '.SF Pro Text',
  '.SF UI Display',
  '.SF UI Text',
];

@Deprecated('Use kFontsToReplaceWithRoboto instead')
const kOverriddenFonts = kFontsToReplaceWithRoboto;
