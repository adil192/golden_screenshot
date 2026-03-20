import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

/// A widget that shows a titlebar if [device] requires it.
///
/// For Linux, it shows a titlebar resembling GNOME's Adwaita decorations.
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
    if (device.platform != TargetPlatform.linux) return child;

    final colorScheme = ColorScheme.of(context);
    return Scaffold(
      appBar:
          titleBar ??
          AppBar(
            toolbarHeight: 46,
            backgroundColor: colorScheme.surface,
            scrolledUnderElevation: 0,
            leadingWidth: 46,
            leading: SizedBox.square(dimension: 46),
            title: DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'Adwaita Sans',
                fontSize: 14,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              child: Center(child: title),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all((46 - 24) / 2),
                child: Image(image: ScreenshotFrame.flathubCloseButtonImage),
              ),
            ],
          ),
      body: child,
    );
  }
}
