import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:golden_screenshot/src/device_box.dart';

/// A [MaterialApp] that produces golden images
/// with [device]'s resolution, pixel ratio, and frame.
class ScreenshotApp extends MaterialApp {
  const ScreenshotApp({
    super.key,
    required this.device,
    this.frameColors,
    @Deprecated('Use home instead') Widget? child,
    super.navigatorKey,
    super.scaffoldMessengerKey,
    required super.home,
    super.routes,
    super.initialRoute,
    super.onGenerateRoute,
    super.onGenerateInitialRoutes,
    super.onUnknownRoute,
    super.onNavigationNotification,
    super.navigatorObservers,
    super.builder,
    super.title,
    super.onGenerateTitle,
    super.color,
    super.theme,
    super.darkTheme,
    super.highContrastTheme,
    super.highContrastDarkTheme,
    super.themeMode,
    super.themeAnimationDuration = Duration.zero,
    super.themeAnimationCurve,
    super.locale,
    super.localizationsDelegates,
    super.localeListResolutionCallback,
    super.localeResolutionCallback,
    super.supportedLocales,
    super.debugShowMaterialGrid,
    super.showPerformanceOverlay,
    super.checkerboardRasterCacheImages,
    super.checkerboardOffscreenLayers,
    super.showSemanticsDebugger,
    super.debugShowCheckedModeBanner = false,
    super.shortcuts,
    super.actions,
    super.restorationScopeId,
    super.scrollBehavior,
    super.themeAnimationStyle = AnimationStyle.noAnimation,
  });

  /// A [ScreenshotApp] that includes a title bar if the device is running
  /// Linux or Windows.
  /// For other platforms, it behaves the same as [ScreenshotApp].
  ScreenshotApp.withConditionalTitlebar({
    super.key,
    required this.device,
    this.frameColors,
    @Deprecated('Use home instead') Widget? child,
    super.navigatorKey,
    super.scaffoldMessengerKey,
    required super.home,
    super.routes,
    super.initialRoute,
    super.onGenerateRoute,
    super.onGenerateInitialRoutes,
    super.onUnknownRoute,
    super.onNavigationNotification,
    super.navigatorObservers,
    TransitionBuilder? builder,
    // Title is required for the title bar.
    required String super.title,
    super.onGenerateTitle,
    super.color,
    super.theme,
    super.darkTheme,
    super.highContrastTheme,
    super.highContrastDarkTheme,
    super.themeMode,
    super.themeAnimationDuration = Duration.zero,
    super.themeAnimationCurve,
    super.locale,
    super.localizationsDelegates,
    super.localeListResolutionCallback,
    super.localeResolutionCallback,
    super.supportedLocales,
    super.debugShowMaterialGrid,
    super.showPerformanceOverlay,
    super.checkerboardRasterCacheImages,
    super.checkerboardOffscreenLayers,
    super.showSemanticsDebugger,
    super.debugShowCheckedModeBanner = false,
    super.shortcuts,
    super.actions,
    super.restorationScopeId,
    super.scrollBehavior,
    super.themeAnimationStyle = AnimationStyle.noAnimation,
    bool? isClosable,
    bool? isMaximizable,
    bool? isMinimizable,
  }) : super(
         builder: (context, child) {
           return ScreenshotConditionalTitlebar(
             title: Text(title),
             device: device,
             isClosable: isClosable,
             isMaximizable: isMaximizable,
             isMinimizable: isMinimizable,
             child:
                 builder?.call(context, child) ??
                 child ??
                 const SizedBox.expand(),
           );
         },
       );

  /// The device whose resolution and pixel ratio will be simulated,
  /// and whose frame will be drawn around the [home] widget.
  final ScreenshotDevice device;

  /// The colors of the device frame.
  final ScreenshotFrameColors? frameColors;

  /// This property has been replaced with [home].
  @Deprecated('Use home instead.')
  Widget? get child => home;

  @override
  State<ScreenshotApp> createState() => _ScreenshotAppState();
}

class _ScreenshotAppState extends State<ScreenshotApp> {
  @override
  void initState() {
    super.initState();
    debugDefaultTargetPlatformOverride = widget.device.platform;
  }

  @override
  void dispose() {
    debugDefaultTargetPlatformOverride = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DeviceBox.fromDevice(
      device: widget.device,
      mediaQueryData: MediaQueryData(
        disableAnimations:
            widget.themeAnimationStyle == AnimationStyle.noAnimation,
      ),
      child: MaterialApp(
        navigatorKey: widget.navigatorKey,
        scaffoldMessengerKey: widget.scaffoldMessengerKey,
        routes: widget.routes ?? const <String, WidgetBuilder>{},
        initialRoute: widget.initialRoute,
        onGenerateRoute: widget.onGenerateRoute,
        onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
        onUnknownRoute: widget.onUnknownRoute,
        onNavigationNotification: widget.onNavigationNotification,
        navigatorObservers:
            widget.navigatorObservers ?? const <NavigatorObserver>[],
        title: widget.title,
        onGenerateTitle: widget.onGenerateTitle,
        color: widget.color,
        theme:
            widget.theme?.copyWith(platform: widget.device.platform) ??
            // Fallback so the platform is always set.
            ThemeData(platform: widget.device.platform),
        darkTheme: widget.darkTheme?.copyWith(platform: widget.device.platform),
        highContrastTheme: widget.highContrastTheme?.copyWith(
          platform: widget.device.platform,
        ),
        highContrastDarkTheme: widget.highContrastDarkTheme?.copyWith(
          platform: widget.device.platform,
        ),
        themeMode: widget.themeMode,
        themeAnimationDuration: widget.themeAnimationDuration,
        themeAnimationCurve: widget.themeAnimationCurve,
        locale: widget.locale,
        localizationsDelegates: widget.localizationsDelegates,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        localeResolutionCallback: widget.localeResolutionCallback,
        supportedLocales: widget.supportedLocales,
        debugShowMaterialGrid: widget.debugShowMaterialGrid,
        showPerformanceOverlay: widget.showPerformanceOverlay,
        checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
        showSemanticsDebugger: widget.showSemanticsDebugger,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        shortcuts: widget.shortcuts,
        actions: widget.actions,
        restorationScopeId: widget.restorationScopeId,
        scrollBehavior: widget.scrollBehavior,
        themeAnimationStyle: widget.themeAnimationStyle,
        builder: (context, child) {
          return widget.device.frameBuilder(
            device: widget.device,
            frameColors: widget.frameColors,
            child:
                widget.builder?.call(context, child) ??
                child ??
                const SizedBox.expand(),
          );
        },
        home: widget.home,
      ),
    );
  }
}
