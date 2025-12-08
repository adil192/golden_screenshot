import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  testGoldens('fontsToMock', (tester) async {
    await tester.loadAssets(
      // This fix isn't working for some reason :(
      overriddenFonts: ['Comic Sans', ...kOverriddenFonts],
    );

    await tester.runAsync(
      () => loadAppFonts(overriddenFonts: ['Comic Sans', ...kOverriddenFonts]),
    );
  });
}
