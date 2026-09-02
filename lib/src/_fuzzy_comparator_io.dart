import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_screenshot/src/fuzzy_compare.dart';

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
         // The actual file doesn't matter, just the directory.
         Uri.parse(
           '${(previousComparator as LocalFileComparator).basedir.path}/some_test.dart',
         ),
       );

  /// How much the golden image and test image can differ (root mean square error).
  ///
  /// The RMSE could be:
  /// - 0.0 if every pixel is exactly the same.
  /// - 1.0 if every pixel is 100% different (e.g. rgba(0,0,0,0.0) to rgba(255,255,255,1.0)).
  /// - 0.01 for a small text change.
  ///
  /// See [kAllowedDiffPercent] for the default.
  final double allowedDiffPercent;

  // Based on https://stackoverflow.com/a/78510535/
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
}
