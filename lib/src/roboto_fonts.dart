import 'package:flutter/services.dart';

abstract class RobotoFonts {
  static const familyWithPackage = 'packages/golden_screenshot/Roboto';

  static final assetFutures = const [
    'packages/golden_screenshot/assets/roboto/Roboto-Thin.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-ThinItalic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-ExtraLight.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-ExtraLightItalic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-Light.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-LightItalic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-Regular.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-Italic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-Medium.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-MediumItalic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-SemiBold.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-SemiBoldItalic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-Bold.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-BoldItalic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-ExtraBold.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-ExtraBoldItalic.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-Black.ttf',
    'packages/golden_screenshot/assets/roboto/Roboto-BlackItalic.ttf',
  ].map(rootBundle.load).toList(growable: false);
}
