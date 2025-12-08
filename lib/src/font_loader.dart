import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/src/apple_fonts.dart';
import 'package:golden_screenshot/src/inter_fonts.dart';

typedef JsonMap = Map<String, dynamic>;

/// Flutter uses the `Ahem` font by default in golden tests
/// which displays a filled rectangle for each character,
/// which of course isn't suitable for app stores.
///
/// This method loads proper fonts for the app to use in golden tests.
///
/// Note: Loading every single font can use up a lot of RAM and slow down
/// your tests. Prefer using [tester.loadAssets] where possible to only load
/// the fonts your widget tree uses, or manually specify [onlyLoadTheseFonts].
///
/// Note: If your app specifies a custom font (e.g. Comic Sans)
/// with font fallbacks, but does not include said custom font,
/// the font fallbacks will not be applied. Ahem will be used instead.
/// In this case, please provide the [fontsToMock] parameter
/// with the fonts that should be forced to use Inter instead of Ahem, e.g.:
///
/// ```dart
/// await loadAppFonts(fontsToMock: ['Comic Sans', ...kFontsToMock]);
/// ```
Future<void> loadAppFonts({
  /// If provided, only these fonts will be loaded.
  ///
  /// This takes precedence over [fontsToMock].
  Set<String>? onlyLoadTheseFonts,

  /// Fonts we don't actually have, so we load Inter in their place.
  ///
  /// If a font is in both [fontsToMock] and [onlyLoadTheseFonts],
  /// [onlyLoadTheseFonts] takes precedence and the font will not be loaded.
  ///
  /// If Apple fonts are in [fontsToMock] but they're actually
  /// available, the real fonts will be used instead of Inter.
  Iterable<String> fontsToMock = kFontsToMock,

  /// This was renamed to [fontsToMock] for clarity.
  @Deprecated('This was renamed to fontsToMock')
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
    if (onlyLoadTheseFonts != null && !onlyLoadTheseFonts.contains(family)) {
      continue;
    }
    fontLoadingFutures.add(_loadFontAsset(family, fontObject));
  }
  final wantsAppleFonts =
      onlyLoadTheseFonts?.any(_appleFontFamilies.contains) ?? true;
  if (wantsAppleFonts && AppleFonts.available) {
    await for (final (:family, :fonts) in AppleFonts.getFontFamilies()) {
      if (onlyLoadTheseFonts != null && !onlyLoadTheseFonts.contains(family)) {
        continue;
      }
      fontLoadingFutures.add(_loadFontFiles(family, fonts));
    }
  }

  // Now override [fontsToMock]
  for (final family in fontsToMock.toSet()..addAll(overriddenFonts)) {
    if (onlyLoadTheseFonts != null && !onlyLoadTheseFonts.contains(family)) {
      continue;
    }
    if (_appleFontFamilies.contains(family) && AppleFonts.available) {
      // Apple fonts are available, no need to override them with Inter
      continue;
    }
    fontLoadingFutures.add(_loadInter(family));
  }

  await Future.wait(fontLoadingFutures);
}

Future<void> _loadFontAsset(String family, JsonMap fontObject) {
  final fontLoader = FontLoader(family);
  for (final JsonMap fontDef in fontObject['fonts'] as List) {
    final assetPath = fontDef['asset'] as String;
    final assetBytesFuture = rootBundle.load(assetPath);
    fontLoader.addFont(assetBytesFuture);
  }
  return fontLoader.load();
}

/// Different to [_loadFontAsset] because we don't want to read the asset
/// into memory multiple times. [InterFonts.assetFutures] is only created once.
Future<void> _loadInter(String family) async {
  final fontLoader = FontLoader(family);
  for (final assetBytesFuture in InterFonts.assetFutures) {
    fontLoader.addFont(assetBytesFuture);
  }
  return fontLoader.load();
}

Future<void> _loadFontFiles(String family, List<Uint8List> files) {
  final fontLoader = FontLoader(family);
  for (final file in files) {
    final assetBytesFuture = Future.value(ByteData.view(file.buffer));
    fontLoader.addFont(assetBytesFuture);
  }
  return fontLoader.load();
}

/// The fonts overridden by Inter in [loadAppFonts].
///
/// This list represents the default fonts used by Flutter on various platforms.
const kFontsToMock = {
  // Android
  'Inter',
  'Roboto',

  // Linux
  'Adwaita Sans',
  'Cantarell',
  'Noto Sans',
  'Ubuntu',

  // Windows
  'Segoe UI',

  // Apple
  ..._appleFontFamilies,

  // Other
  'system-ui',
  'sans-serif',
};

const _appleFontFamilies = {
  'CupertinoSystemDisplay',
  'CupertinoSystemText',
  '.AppleSystemUIFont',
  '.SF Pro Display',
  '.SF Pro Text',
  '.SF UI Display',
  '.SF UI Text',
};

@Deprecated('Use kFontsToMock instead')
const kFontsToReplaceWithRoboto = kFontsToMock;

@Deprecated('Use kFontsToMock instead')
const kOverriddenFonts = kFontsToMock;
