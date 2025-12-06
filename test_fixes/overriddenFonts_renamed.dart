import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  testGoldens('fontsToReplaceWithRoboto', (tester) async {
    // This fix isn't working for some reason :(
    await tester
        .loadAssets(overriddenFonts: ['Comic Sans', ...kOverriddenFonts]);

    await tester.runAsync(() => loadAppFonts(
          overriddenFonts: ['Comic Sans', ...kOverriddenFonts],
        ));
  });
}
