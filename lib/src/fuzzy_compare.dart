import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart' hide compareLists;
import 'package:flutter_test/flutter_test.dart' as flutter_test;

/// Returns a [ComparisonResult] to describe the pixel differential of the
/// [test] and [master] image bytes provided.
///
/// Based on [flutter_test.compareLists].
///
/// Our implementation returns the root mean squared error between the two images,
/// whereas Flutter's implementation simply returns the ratio of pixels changed,
/// even if they only changed a tiny bit.
/// This means the `diffPercent` from our implementation will be smaller than Flutter's.
///
/// Our implementation doesn't produce `maskedDiff` and `isolatedDiff` images for performance.
/// If needed, you can compare the [test] and [master] images with GitHub Desktop or another utility.
Future<ComparisonResult> fuzzyCompare(
  Uint8List test,
  Uint8List master,
  double allowedDiffPercent,
) async {
  if (test.isEmpty || master.isEmpty) {
    return ComparisonResult(
      passed: false,
      diffPercent: 1.0,
      error: 'Pixel test failed: empty image provided.',
    );
  }

  if (listEquals(test, master)) {
    return ComparisonResult(passed: true, diffPercent: 0.0);
  }

  final testImage = await _decodeImage(test);
  final testImageRgba = (await testImage.toByteData(format: .rawRgba))!;

  final masterImage = await _decodeImage(master);
  final masterImageRgba = (await masterImage.toByteData(format: .rawRgba))!;

  if (testImage.width != masterImage.width ||
      testImage.height != masterImage.height) {
    return ComparisonResult(
      passed: false,
      diffPercent: 1.0,
      error:
          'Pixel test failed: image sizes do not match.\n'
          'Master Image: ${masterImage.width} X ${masterImage.height}\n'
          'Test Image: ${testImage.width} X ${testImage.height}',
      diffs: {'masterImage': masterImage, 'testImage': testImage},
    );
  }
  final width = testImage.width;
  final height = testImage.height;
  final totalPixels = width * height;

  var totalSquaredError = 0.0;
  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      final byteOffset = (width * y + x) * 4;
      final testPixel = testImageRgba.getUint32(byteOffset);
      final masterPixel = masterImageRgba.getUint32(byteOffset);

      final squaredError =
          _square(_readRed(testPixel) / 255 - _readRed(masterPixel) / 255) +
          _square(_readGreen(testPixel) / 255 - _readGreen(masterPixel) / 255) +
          _square(_readBlue(testPixel) / 255 - _readBlue(masterPixel) / 255) +
          _square(_readAlpha(testPixel) / 255 - _readAlpha(masterPixel) / 255);
      totalSquaredError += squaredError;
    }
  }

  final diffPercent = sqrt(totalSquaredError / (totalPixels * 4));
  if (diffPercent > allowedDiffPercent) {
    return ComparisonResult(
      passed: false,
      diffPercent: diffPercent,
      error:
          'Pixel test failed: '
          '${(diffPercent * 100).toStringAsFixed(2)}% diff detected.',
      diffs: <String, Image>{
        'masterImage': masterImage,
        'testImage': testImage,
      },
    );
  }

  masterImage.dispose();
  testImage.dispose();
  return ComparisonResult(passed: true, diffPercent: diffPercent);
}

/// Reads the red value out of a 32 bit rgba pixel.
int _readRed(int pixel) => (pixel >> 24) & 0xff;

/// Reads the green value out of a 32 bit rgba pixel.
int _readGreen(int pixel) => (pixel >> 16) & 0xff;

/// Reads the blue value out of a 32 bit rgba pixel.
int _readBlue(int pixel) => (pixel >> 8) & 0xff;

/// Reads the alpha value out of a 32 bit rgba pixel.
int _readAlpha(int pixel) => pixel & 0xff;

/// Convert an encoded image into an [Image] object.
///
/// A narrowed form of [instantiateImageCodec].
Future<Image> _decodeImage(Uint8List bytes) async {
  final buffer = await ImmutableBuffer.fromUint8List(bytes);
  try {
    final descriptor = await ImageDescriptor.encoded(buffer);
    try {
      final codec = await descriptor.instantiateCodec();
      try {
        final frameInfo = await codec.getNextFrame();
        return frameInfo.image;
      } finally {
        codec.dispose();
      }
    } finally {
      descriptor.dispose();
    }
  } finally {
    buffer.dispose();
  }
}

double _square(double x) => x * x;
