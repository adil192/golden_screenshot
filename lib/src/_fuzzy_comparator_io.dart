import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_screenshot/src/fuzzy_compare.dart';
import 'package:path/path.dart' as path;

const alwaysUpdateGoldens = bool.fromEnvironment(
  'GOLDEN_SCREENSHOT_ALWAYS_UPDATE_GOLDENS',
);

/// A golden file comparator that differs from the default one by allowing
/// a small amount of difference between the golden and the test image.
class FuzzyComparator extends LocalFileComparator {
  FuzzyComparator({
    required dynamic previousComparator,
    required this.allowedDiffPercent,
  }) : assert(
         previousComparator is LocalFileComparator,
         'previousComparator must be a LocalFileComparator on non-web, got $previousComparator',
       ),
       super(
         // The actual file doesn't matter, just the basedir.
         (previousComparator as LocalFileComparator).basedir.resolve(
           'some_test.dart',
         ),
       );

  /// How much the golden image and test image can differ (root mean square error)
  /// without failing the test.
  ///
  /// The RMSE could be:
  /// - 0.0 if every pixel is exactly the same.
  /// - 1.0 if every pixel is 100% different in at least one rgba channel
  ///   (e.g. black vs white / transparent vs opaque / pure red vs pure blue).
  /// - 0.01 for a small text change.
  ///
  /// See also:
  /// - [kAllowedDiffPercent] for the default value.
  /// - [fuzzyCompare] for the RMSE implementation.
  final double allowedDiffPercent;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await fuzzyCompare(
      imageBytes,
      await getGoldenBytes(golden) as Uint8List,
      allowedDiffPercent,
    );

    try {
      if (result.passed) return true;
      throw FlutterError(await generateFailureOutput(result, golden, basedir));
    } finally {
      result.dispose();
    }
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {
    final goldenFile = _getGoldenFile(golden);

    if (!await _shouldUpdateGolden(goldenFile, imageBytes)) return;

    await goldenFile.parent.create(recursive: true);
    await goldenFile.writeAsBytes(imageBytes, flush: true);
  }

  Future<bool> _shouldUpdateGolden(
    File goldenFile,
    Uint8List imageBytes,
  ) async {
    if (alwaysUpdateGoldens) return true;
    if (!goldenFile.existsSync()) return true;

    final goldenBytes = await goldenFile.readAsBytes();
    final result = await fuzzyCompare(
      imageBytes,
      goldenBytes,
      allowedDiffPercent,
    );
    try {
      return !result.passed;
    } finally {
      result.dispose();
    }
  }

  /// Copied from [LocalFileComparator._getGoldenFile].
  File _getGoldenFile(Uri golden) =>
      File(path.join(path.fromUri(basedir), path.fromUri(golden.path)));
}
