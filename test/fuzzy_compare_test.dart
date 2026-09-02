import 'dart:math';
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
      expect(result.diffPercent, equals(1.0));
      expect(result.passed, isFalse);
      expect(result.error, 'Pixel test failed: empty image provided.');
    });

    test('same image', () async {
      final test = _pixels([0, 0, 0, 0]);
      final master = _pixels([0, 0, 0, 0]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.diffPercent, equals(0.0));
      expect(result.passed, isTrue);
      expect(result.error, isNull);
    });

    test('different size', () async {
      final test = _pixels([0, 0, 0, 0, 0, 0, 0, 0]);
      final master = _pixels([0, 0, 0, 0]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.diffPercent, equals(1.0));
      expect(result.passed, isFalse);
      expect(
        result.error,
        startsWith('Pixel test failed: image sizes do not match.'),
      );
    });

    test('black vs white', () async {
      final test = _pixels([0, 0, 0, 255]);
      final master = _pixels([255, 255, 255, 255]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.diffPercent, _roughly(1.0));
      expect(result.passed, isFalse);
      expect(result.error, startsWith('Pixel test failed'));
      expect(result.error, endsWith('% diff detected.'));
    });

    test('gray vs white', () async {
      final test = _pixels([128, 128, 128, 255]);
      final master = _pixels([255, 255, 255, 255]);
      final result = await fuzzyCompare(test, master, 0.0);
      addTearDown(result.dispose);
      expect(result.diffPercent, _roughly(0.498));
      expect(result.passed, isFalse);
    });

    test('gray vs white, allowedDiffPercent', () async {
      final test = _pixels([128, 128, 128, 255]);
      final master = _pixels([255, 255, 255, 255]);
      final result = await fuzzyCompare(test, master, 0.5);
      addTearDown(result.dispose);
      expect(result.diffPercent, _roughly(0.498));
      expect(result.passed, isTrue);
    });

    test('opaque vs transparent', () async {
      final test = _pixels([255, 255, 255, 255]);
      final master = _pixels([255, 255, 255, 0]);
      final result = await fuzzyCompare(test, master, 1.0);
      addTearDown(result.dispose);
      expect(result.diffPercent, _roughly(1.0));
    });
    test('red vs green', () async {
      final test = _pixels([255, 0, 0, 255]);
      final master = _pixels([0, 255, 0, 255]);
      final result = await fuzzyCompare(test, master, 1.0);
      addTearDown(result.dispose);
      expect(result.diffPercent, _roughly(1.0));
    });

    test('1 pixel changed, 2 pixels unchanged', () async {
      final test = _pixels([
        255, 255, 255, 255,
        255, 255, 255, 255, // <!--
        255, 255, 255, 255,
      ]);
      final master = _pixels([
        255, 255, 255, 255,
        0, 0, 0, 0, // <!--
        255, 255, 255, 255,
      ]);
      final result = await fuzzyCompare(test, master, 1.0);
      addTearDown(result.dispose);
      expect(result.diffPercent, _roughly(sqrt(1 / 3)));
    });
  });
}

Matcher _roughly(double value) => moreOrLessEquals(value, epsilon: 0.001);

Uint8List _pixels(List<int> rgbas) {
  final image = img.Image(width: rgbas.length ~/ 4, height: 1, numChannels: 4);
  for (final pixel in image) {
    pixel
      ..r = rgbas[pixel.x * 4]
      ..g = rgbas[pixel.x * 4 + 1]
      ..b = rgbas[pixel.x * 4 + 2]
      ..a = rgbas[pixel.x * 4 + 3];
  }
  return img.encodePng(image, level: 0);
}
