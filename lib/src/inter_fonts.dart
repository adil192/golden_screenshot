import 'package:flutter/services.dart';

abstract class InterFonts {
  static final assetFutures = const [
    'packages/golden_screenshot/assets/Inter/Inter_24pt-Black.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-BlackItalic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-Bold.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-BoldItalic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-ExtraBold.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-ExtraBoldItalic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-ExtraLight.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-ExtraLightItalic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-Italic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-Light.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-LightItalic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-Medium.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-MediumItalic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-Regular.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-SemiBold.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-SemiBoldItalic.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-Thin.ttf',
    'packages/golden_screenshot/assets/Inter/Inter_24pt-ThinItalic.ttf',
  ].map(rootBundle.load).toList(growable: false);
}
