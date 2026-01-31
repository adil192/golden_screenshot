import 'package:flutter/services.dart';

abstract class InterFonts {
  static final assetFutures = const [
    // We're now using Inter augmented with Noto Sans for more language support.
    // See https://github.com/adil192/inter-noto-hybrid
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-Regular.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-Black.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-Bold.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-ExtraBold.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-ExtraLight.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-Light.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-Medium.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-SemiBold.ttf',
    'packages/golden_screenshot/assets/InterNotoSansHybrid/InterNotoSansHybrid-Thin.ttf',
  ].map(rootBundle.load).toList(growable: false);
}
