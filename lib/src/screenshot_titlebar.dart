import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:yaru/yaru.dart';

/// A widget that shows a titlebar if [device] requires it.
///
/// For Linux and Windows devices, it shows a titlebar from the Yaru package.
/// For other platforms, it simply returns [child] without modification.
///
/// Example usage:
/// ```dart
/// tester.pumpWidget(ScreenshotApp(
///   device: myDevice,
///   home: ScreenshotConditionalTitlebar(
///     title: Text('My App'),
///     device: myDevice,
///     child: MyApp(),
///   ),
/// ));
/// ```
class ScreenshotConditionalTitlebar extends StatelessWidget {
  const ScreenshotConditionalTitlebar({
    super.key,
    required this.title,
    required this.device,
    required this.child,
  }) : titleBar = null;

  const ScreenshotConditionalTitlebar.manual({
    super.key,
    required this.titleBar,
    required this.device,
    required this.child,
  }) : title = null;

  final PreferredSizeWidget? titleBar;
  final Widget? title;
  final ScreenshotDevice device;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final yaruPlatform = switch (device.platform) {
      TargetPlatform.linux => YaruWindowControlPlatform.yaru,
      TargetPlatform.windows => YaruWindowControlPlatform.windows,
      _ => null,
    };
    if (yaruPlatform == null) {
      return child;
    }

    return Scaffold(
      appBar: titleBar ??
          YaruWindowTitleBar(
            title: title,
            isActive: true,
            isClosable: true,
            isMaximizable: true,
            isMinimizable: true,
            platform: yaruPlatform,
          ),
      body: child,
    );
  }
}
