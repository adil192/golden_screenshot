import 'package:golden_screenshot/src/fuzzy_comparator.dart';

export '_fuzzy_comparator_io.dart'
    if (dart.library.js_interop) '_fuzzy_comparator_web.dart';

@Deprecated('Use FuzzyComparator instead')
class ScreenshotComparator extends FuzzyComparator {
  ScreenshotComparator({
    required super.previousComparator,
    required super.allowedDiffPercent,
  });
}
