// ignore_for_file: avoid_print

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:golden_screenshot/src/apple_fonts.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  if (!File('pubspec.yaml').existsSync()) {
    throw StateError(
      'This script must be run from the root of your Flutter app.',
    );
  }
  await _AppleFontsDownloader.downloadFonts();
}

extension _AppleFontsDownloader on AppleFonts {
  static final fontsDirectory = AppleFonts.fontsDirectory;
  static final fontsZipFile = AppleFonts.fontsZipFile;

  static Future<void> downloadFonts() async {
    print('Use of Apple fonts is subject to their license: '
        'https://developer.apple.com/fonts/'
        '\n');

    if (fontsDirectory.existsSync()) {
      print('Apple system fonts already downloaded at ${fontsDirectory.path}');
      return;
    }

    await _downloadZip();
    await _checkZipHash();
    await _extractFonts();
    await _deleteZip();
  }

  static Future<void> _downloadZip() async {
    if (fontsZipFile.existsSync()) {
      print('Already downloaded: ${fontsZipFile.path}');
      return;
    }

    final uri = Uri.parse(
      'https://github.com/apple-fonts/Apple-system-fonts/releases/download/2023-06-06/Apple-system-fonts.zip',
    );
    final client = HttpClient()
      // Respect the http(s)_proxy environment variables.
      ..findProxy = HttpClient.findProxyFromEnvironment;
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('The request to $uri failed.', uri: uri);
    }
    await fontsZipFile.create();
    await response.pipe(fontsZipFile.openWrite());
    print('Downloaded Apple system fonts to ${fontsZipFile.path}');
  }

  static Future<void> _checkZipHash() async {
    final hash = await _hashFile(fontsZipFile);
    const expectedHash =
        '834752b0a556ee8b716af2a4b6259c27473f4890b93bc1352467a3ed6bde3130';
    if (hash != expectedHash) {
      throw Exception(
          'Downloaded file hash does not match expected hash: $hash');
    } else {
      print('Hash verified for ${fontsZipFile.path}');
    }
  }

  static Future<String> _hashFile(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  static Future<void> _extractFonts() async {
    final inputStream = InputFileStream(fontsZipFile.path);
    final archive = ZipDecoder().decodeStream(inputStream);
    var numFiles = 0;
    for (final file in archive) {
      if (!file.isFile) continue;
      final fileName = p.basename(file.name);
      final outputFile = File(p.join(fontsDirectory.path, fileName));
      await outputFile.create(recursive: true);
      final outputStream = OutputFileStream(outputFile.path);
      file.writeContent(outputStream);
      outputStream.closeSync();
      numFiles++;
    }
    print('Extracted $numFiles fonts to ${fontsDirectory.path}');
    await inputStream.close();
  }

  static Future<void> _deleteZip() async {
    await fontsZipFile.delete();
    print('Deleted ${fontsZipFile.path}');
  }
}
