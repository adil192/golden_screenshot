// ignore: implementation_imports
import 'package:flutter_test/src/_goldens_web.dart';

/// An unsupported [GoldenFileComparator] that exists for API compatibility.
class FuzzyComparator extends LocalFileComparator {
  FuzzyComparator({
    required dynamic previousComparator,
    required this.allowedDiffPercent,
  });

  final double allowedDiffPercent;
}
