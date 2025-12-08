import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:yaru/yaru.dart';

/// A widget that shows a titlebar if [device] requires it.
///
/// For Linux and Windows devices, it shows a titlebar from the Yaru package.
/// For other platforms, it simply returns [child] without modification.
///
/// It is recommended to use this widget inside the [builder] of [ScreenshotApp]
/// to ensure that the titlebar isn't affected by dialog backdrops or other
/// effects.
///
/// Example usage:
/// ```dart
/// tester.pumpWidget(ScreenshotApp(
///   device: device,
///   builder: (context, child) {
///     return ScreenshotConditionalTitlebar(
///       title: Text('My App'),
///       device: myDevice,
///       child: child!,
///     );
///   },
///   home: MyApp(),
/// ));
/// ```
///
/// Preferably, use the [ScreenshotApp.withConditionalTitlebar] constructor
/// instead of using this widget directly.
/// ```dart
/// tester.pumpWidget(ScreenshotApp.withConditionalTitlebar(
///   device: device,
///   title: 'My App',
///   home: MyApp(),
/// ));
/// ```
class ScreenshotConditionalTitlebar extends StatelessWidget {
  const ScreenshotConditionalTitlebar({
    super.key,
    required this.title,
    required this.device,
    required this.child,
    this.isClosable,
    this.isMaximizable,
    this.isMinimizable,
  }) : titleBar = null;

  const ScreenshotConditionalTitlebar.manual({
    super.key,
    required this.titleBar,
    required this.device,
    required this.child,
  }) : title = null,
       isClosable = null,
       isMaximizable = null,
       isMinimizable = null;

  final PreferredSizeWidget? titleBar;
  final Widget? title;
  final ScreenshotDevice device;
  final Widget child;
  final bool? isClosable;
  final bool? isMaximizable;
  final bool? isMinimizable;

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

    /// On Linux, only show the close button by default, not maximize/minimize.
    /// https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/quality-guidelines#default-settings
    final onlyClosable = yaruPlatform == YaruWindowControlPlatform.yaru;

    return Scaffold(
      appBar:
          titleBar ??
          YaruWindowTitleBar(
            title: title,
            isActive: true,
            isClosable: isClosable ?? true,
            isMaximizable: isMaximizable ?? !onlyClosable,
            isMinimizable: isMinimizable ?? !onlyClosable,
            platform: yaruPlatform,
          ),
      body: child,
    );
  }
}
