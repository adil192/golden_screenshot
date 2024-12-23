import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart' hide DefaultWebGoldenComparator;
// ignore: implementation_imports
import 'package:flutter_test/src/_goldens_web.dart';

import 'package:web/web.dart' as web;

/// A golden file comparator that differs from the default one by allowing
/// a small amount of difference between the golden and the test image.
class FuzzyComparator extends DefaultWebGoldenComparator {
  FuzzyComparator({
    required dynamic previousComparator,
    required this.allowedDiffPercent,
  })  : assert(previousComparator is DefaultWebGoldenComparator,
            'previousComparator must be a DefaultWebGoldenComparator on web, got $previousComparator'),
        super(
          (previousComparator as DefaultWebGoldenComparator).testUri,
        );

  /// How much the golden image can differ from the test image.
  /// E.g. 0.1 means 0.1% difference is allowed.
  final double allowedDiffPercent;

  @override
  Future<bool> compare(double width, double height, Uri golden) async {
    final String key = golden.toString();
    final web.Response response = await web.window
        .fetch(
            'flutter_goldens'.toJS,
            web.RequestInit(
              method: 'POST',
              body: json.encode(<String, Object>{
                'testUri': testUri.toString(),
                'key': key,
                'width': width.round(),
                'height': height.round(),
              }).toJS,
            ))
        .toDart;
    final String responseText = (await response.text().toDart).toDart;
    if (responseText == 'true') {
      return true;
    }
    // TODO(adil192): Figure out how to apply the diff percent here
    fail(responseText);
  }
}
