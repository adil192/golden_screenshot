import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/src/fuzzy_compare.dart';
import 'package:image/image.dart' as img;

void main() {
  group('fuzzyCompare', () {
    test('empty image', () async {
      final image = Uint8List(0);
      final result = await fuzzyCompare(image, image, 1.0);
      addTearDown(result.dispose);
      expect(result.passed, isFalse);
      expect(result.diffPercent, 1.0);
      expect(result.error, 'Pixel test failed: empty image provided.');
    });

    test('same image', () async {
      final test = _pixels([0, 0, 0, 0]);
      final master = _pixels([0, 0, 0, 0]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.passed, isTrue);
      expect(result.diffPercent, 0.0);
      expect(result.error, isNull);
    });

    test('different size', () async {
      final test = _pixels([0, 0, 0, 0, 0, 0, 0, 0]);
      final master = _pixels([0, 0, 0, 0]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.passed, isFalse);
      expect(result.diffPercent, 1.0);
      expect(
        result.error,
        startsWith('Pixel test failed: image sizes do not match.'),
      );
    });

    test('black and white', () async {
      final test = _pixels([0, 0, 0, 255]);
      final master = _pixels([255, 255, 255, 255]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.passed, isFalse);
      expect(result.diffPercent, moreOrLessEquals(0.8660254037844386));
      expect(result.error, startsWith('Pixel test failed'));
      expect(result.error, endsWith('% diff detected.'));
    });

    test('gray and white', () async {
      final test = _pixels([128, 128, 128, 255]);
      final master = _pixels([255, 255, 255, 255]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.passed, isFalse);
      expect(result.diffPercent, moreOrLessEquals(0.431314612865191));
    });

    test('allowedDiffPercent', () async {
      final test = _pixels([128, 128, 128, 255]);
      final master = _pixels([255, 255, 255, 255]);
      final result = await fuzzyCompare(test, master, 0.5);
      addTearDown(result.dispose);
      expect(result.passed, isTrue);
      expect(result.diffPercent, moreOrLessEquals(0.431314612865191));
    });
  });
}

Uint8List _pixels(List<int> rgbas) {
  final image = img.Image(width: rgbas.length ~/ 4, height: 1);
  for (final pixel in image) {
    pixel
      ..r = rgbas[pixel.x]
      ..g = rgbas[pixel.x + 1]
      ..b = rgbas[pixel.x + 2]
      ..a = rgbas[pixel.x + 3];
  }
  return img.encodePng(image, level: 0);
}
