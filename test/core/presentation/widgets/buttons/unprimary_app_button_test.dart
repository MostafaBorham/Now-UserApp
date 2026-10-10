import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/fonts.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('the label keeps the theme font', (WidgetTester tester) async {
    // The button's Material replaces the ambient text style instead of
    // merging, so a style without a family would fall back to the system font.
    await pumpCategoriesWidget(
      tester,
      UnPrimaryAppButton(title: 'Reset', onTap: () {}),
    );

    final RenderParagraph label = tester.renderObject(find.text('Reset'));
    expect(label.text.style!.fontFamily, FontFamily.cairo);
  });
}
