// ignore_for_file: avoid_print

import 'dart:io';

import 'package:golden_screenshot/src/apple_fonts.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  await _AppleFontsDownloader.downloadFonts();
}

extension _AppleFontsDownloader on AppleFonts {
  static Future<void> downloadFonts() async {
    print(
        'This script will download and extract the fonts directly from Apple.');
    print('Do not redistribute the fonts or bundle them in production.');
    print('See the license for details: https://developer.apple.com/fonts/');
    print('');

    if (AppleFonts.allOtfFiles.isNotEmpty) {
      print('Apple system fonts already downloaded at ${fontsDirectory.path}');
      return;
    }

    await _downloadDmg();
    await _findOrDownload7z();
    await _extractDmg();
    await Directory(_tmp).delete(recursive: true);
  }

  static final fontsDirectory = AppleFonts.fontsDirectory;

  static final _tmp =
      Directory.systemTemp.createTempSync('golden_screenshot').path;
  static final _tmpDmgFile = File(p.join(_tmp, 'SF-Pro.dmg'));
  static String? _sevenZipBinary;

  static Future<void> _downloadDmg() async {
    const url =
        'https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg';
    print('Downloading Apple fonts from $url ...');
    final uri = Uri.parse(url);
    await _download(uri, _tmpDmgFile);
  }

  static Future<void> _findOrDownload7z() async {
    if (_sevenZipBinary != null) return;

    // See if 7z is already installed.
    for (final cmd in [
      '7zzs',
      '7zz',
      '7z',
      if (Platform.isWindows) 'C:\\Program Files\\7-Zip\\7z.exe',
      if (Platform.isWindows) 'C:\\Program Files (x86)\\7-Zip\\7z.exe',
    ]) {
      try {
        final result = Process.runSync(cmd, []);
        if (result.exitCode != 0) continue;
      } on ProcessException {
        continue;
      }
      print('Using $cmd from PATH.');
      _sevenZipBinary = cmd;
      return;
    }

    // Download 7zr binary.
    final url = _sevenZipDownloadUrl;
    print('Downloading 7zr binary from $url ...');
    final uri = Uri.parse(url);
    final downloadedFile = File(p.join(_tmp, p.basename(url)));
    await _download(uri, downloadedFile);

    if (p.extension(downloadedFile.path).toLowerCase() == '.exe') {
      _sevenZipBinary = downloadedFile.path;
      return;
    }

    // Extract the archive and find the 7zr binary.
    final extractedDir = Directory(p.join(_tmp, 'extracted7z'))..createSync();
    final tarResult = await Process.run(
        'tar', ['-xf', downloadedFile.path, '-C', extractedDir.path]);
    if (tarResult.exitCode != 0) {
      throw StateError(
          'Failed to extract 7zr archive: ${tarResult.stderr}\n${tarResult.stdout}');
    }
    final extracted7zzs = File(p.join(extractedDir.path, '7zzs'));
    final extracted7zz = File(p.join(extractedDir.path, '7zz'));
    if (extracted7zzs.existsSync()) {
      _sevenZipBinary = extracted7zzs.path;
    } else if (extracted7zz.existsSync()) {
      _sevenZipBinary = extracted7zz.path;
    } else {
      throw StateError(
          'Could not find 7zr binary in extracted archive (${extractedDir.path}).');
    }
  }

  static Future<void> _extractDmg() async {
    final exe = _sevenZipBinary!;
    print('Extracting (1/4) .pkg out of .dmg using $exe...');
    final extractedDmgDir = Directory(p.join(_tmp, 'extracted_dmg'));
    await extractedDmgDir.create(recursive: true);
    var result = await Process.run(
        exe, ['x', _tmpDmgFile.path, '-o${extractedDmgDir.path}', '-y']);
    if (result.exitCode != 0) {
      throw StateError(
          'Failed to extract .dmg: ${result.stderr}\n${result.stdout}');
    }

    print('Extracting (2/4) Payload out of .pkg using $exe...');
    final pkgFile =
        p.join(extractedDmgDir.path, 'SFProFonts', 'SF Pro Fonts.pkg');
    final extractedPkgDir = Directory(p.join(_tmp, 'extracted_pkg'));
    await extractedPkgDir.create(recursive: true);
    result = await Process.run(
        exe, ['x', pkgFile, '-o${extractedPkgDir.path}', '-y']);
    if (result.exitCode != 0) {
      throw StateError(
          'Failed to extract .pkg: ${result.stderr}\n${result.stdout}');
    }

    // Sometimes the above gives us `Payload~` (cpio) directly, sometimes it's
    // `Payload` (gzip) which contains `Payload~` (cpio).
    var payloadCpioFile = p.join(extractedPkgDir.path, 'Payload~');
    if (!File(payloadCpioFile).existsSync()) {
      print('Extracting (3/4) Payload~ out of Payload using $exe...');
      final payloadFile =
          p.join(extractedPkgDir.path, 'SFProFonts.pkg', 'Payload');
      final extractedPayloadDir = Directory(p.join(_tmp, 'extracted_payload'));
      await extractedPayloadDir.create(recursive: true);
      result = await Process.run(
          exe, ['x', payloadFile, '-o${extractedPayloadDir.path}', '-y']);
      if (result.exitCode != 0) {
        throw StateError(
            'Failed to extract Payload: ${result.stderr}\n${result.stdout}');
      }
      payloadCpioFile = p.join(extractedPayloadDir.path, 'Payload~');
    } else {
      print(
          'Extracting (3/4) Payload~ out of Payload not needed, already cpio.');
    }

    print('Extracting (4/4) fonts from Payload~ using $exe...');
    final extractedPayloadCpioDir =
        Directory(p.join(_tmp, 'extracted_payload_cpio'));
    await Process.run(
        exe, ['x', payloadCpioFile, '-o${extractedPayloadCpioDir.path}', '-y']);
    if (result.exitCode != 0) {
      throw StateError(
          'Failed to extract Payload cpio: ${result.stderr}\n${result.stdout}');
    }

    print('Copying fonts to ${fontsDirectory.path}...');
    final fontFiles =
        Directory(p.join(extractedPayloadCpioDir.path, 'Library', 'Fonts'));
    await fontsDirectory.create(recursive: true);
    await for (final entity in fontFiles.list()) {
      if (entity is! File) continue;
      final fileName = p.basename(entity.path);
      final destinationFile = File(p.join(fontsDirectory.path, fileName));
      await entity.copy(destinationFile.path);
    }
  }

  static Future<void> _download(Uri uri, File destination) async {
    final client = HttpClient()
      // Respect the http(s)_proxy environment variables.
      ..findProxy = HttpClient.findProxyFromEnvironment;
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('The request to $uri failed.', uri: uri);
    }
    await destination.create(recursive: true);
    await response.pipe(destination.openWrite());
    print('Downloaded ${destination.path}.');
  }

  static String get _sevenZipDownloadUrl {
    final arch = Arch.current;
    if (Platform.isWindows) {
      throw UnsupportedError(
          'Please install 7-Zip from https://www.7-zip.org/.\n'
          'If it\'s already installed, consider adding it to your PATH.');
    } else if (Platform.isMacOS) {
      return 'https://github.com/ip7z/7zip/releases/download/25.01/7z2501-mac.tar.xz';
    } else {
      return switch (arch) {
        Arch.x64 =>
          'https://github.com/ip7z/7zip/releases/download/25.01/7z2501-linux-x64.tar.xz',
        Arch.arm64 =>
          'https://github.com/ip7z/7zip/releases/download/25.01/7z2501-linux-arm64.tar.xz',
      };
    }
  }
}

enum Arch {
  x64,
  arm64;

  static final Arch current = () {
    final archRaw = _currentRaw.trim().toLowerCase();
    if (archRaw.contains('aarch') || archRaw.contains('arm')) {
      return Arch.arm64;
    } else {
      return Arch.x64;
    }
  }();

  static final _currentRaw = () {
    if (Platform.isWindows) {
      final arch = Platform.environment['PROCESSOR_ARCHITECTURE'];
      if (arch != null && arch.isNotEmpty) return arch;
    } else {
      final result = Process.runSync('uname', ['-m']);
      if (result.exitCode == 0) return result.stdout as String;
    }
    print('Could not detect platform architecture, defaulting to x64.');
    return 'x64';
  }();
}
