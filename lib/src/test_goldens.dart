import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A convenience wrapper around [testWidgets] that
/// enables shadows when running the test.
///
/// You are highly recommended to also use `tester.useFuzzyComparator` inside
/// the callback, to prevent your tests from becoming flaky
/// due to small differences in shadow rendering.
///
/// Note that `tester.expectScreenshot` internally calls
/// `tester.useFuzzyComparator` so you don't need to call it manually.
void testGoldens(
  String description,
  WidgetTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  int? retry,
}) =>
    testWidgets(
      description,
      (tester) async {
        debugDisableShadows = false;
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
