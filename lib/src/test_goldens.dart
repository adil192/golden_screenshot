import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

/// A convenience wrapper around [testWidgets] that
/// - enables shadows (which are otherwise disabled in Flutter tests)
/// - uses a fuzzy comparator with [allowedDiffPercent] to allow some leeway
///
/// Note that this method internally calls
/// `tester.useFuzzyComparator` so you don't need to call it separately.
///
/// If you do not wish to use a fuzzy comparator,
/// set [allowedDiffPercent] to 0.
void testGoldens(
  String description,
  WidgetTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  int? retry,
  double allowedDiffPercent = kAllowedDiffPercent,
}) => testWidgets(
  description,
  (tester) async {
    debugDisableShadows = false;
    tester.useFuzzyComparator(allowedDiffPercent: allowedDiffPercent);
    try {
      await callback(tester);
    } finally {
      debugDisableShadows = true;
    }
  },
  skip: skip,
  timeout: timeout,
  semanticsEnabled: semanticsEnabled,
  variant: variant,
  tags: tags,
  retry: retry,
);
