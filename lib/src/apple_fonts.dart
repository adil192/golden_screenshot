// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Utility class to handle Apple system fonts.
///
/// Run `dart run golden_screenshot:download_apple_fonts` to download them.
abstract class AppleFonts {
  static final fontsDirectory = Directory(
    p.join(_pubCache, 'golden_screenshot', 'SF-Pro'),
  )..createSync(recursive: true);

  static final _pubCache =
      Platform.environment['PUB_CACHE'] ??
      (Platform.isWindows
          ? p.join(Platform.environment['LOCALAPPDATA']!, 'Pub', 'Cache')
          : p.join(Platform.environment['HOME']!, '.pub-cache'));

  static final allOtfFiles = fontsDirectory
      .listSync()
      .whereType<File>()
      .where((file) => p.extension(file.path).toLowerCase() == '.otf')
      .toList();
  static final available = (() {
    final available = allOtfFiles.isNotEmpty;
    if (!available) {
      print(
        'Apple fonts are missing: '
        'run `dart run golden_screenshot:download_apple_fonts`.',
      );
    }
    return available;
  })();

  static Stream<({String family, List<Uint8List> fonts})>
  getFontFamilies() async* {
    if (!available) return;

    final sfProDisplayFonts = await Future.wait(
      allOtfFiles
          .where((file) => p.basename(file.path).startsWith('SF-Pro-Display'))
          .map((file) => file.readAsBytes())
          .toList(),
    );
    final sfProTextFonts = await Future.wait(
      allOtfFiles
          .where((file) => p.basename(file.path).startsWith('SF-Pro-Text'))
          .map((file) => file.readAsBytes())
          .toList(),
    );

    yield (family: 'CupertinoSystemDisplay', fonts: sfProDisplayFonts);
    yield (family: 'CupertinoSystemText', fonts: sfProTextFonts);
    yield (family: '.AppleSystemUIFont', fonts: sfProDisplayFonts);
    yield (family: '.SF Pro Display', fonts: sfProDisplayFonts);
    yield (family: '.SF Pro Text', fonts: sfProTextFonts);
    yield (family: '.SF UI Display', fonts: sfProDisplayFonts);
    yield (family: '.SF UI Text', fonts: sfProTextFonts);
  }
}
