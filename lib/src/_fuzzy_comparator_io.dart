import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

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

  /// How much the golden image can differ from the test image.
  /// E.g. 0.1 means 0.1% difference is allowed.
  final double allowedDiffPercent;

  // Based on https://stackoverflow.com/a/78510535/
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    try {
      final passed = result.passed || result.diffPercent <= allowedDiffPercent;
      if (passed) return true;

      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    } finally {
      result.dispose();
    }
  }
}
