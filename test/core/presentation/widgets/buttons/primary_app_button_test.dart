import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/fonts.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_gradient_app_button.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('a disabled button ignores taps but lets its parent see them', (
    WidgetTester tester,
  ) async {
    // The address form wraps its disabled Save in a GestureDetector to say
    // why it cannot save; that only works if the button stays out of the way.
    bool tapped = false;
    bool parentTapped = false;
    await pumpCategoriesWidget(
      tester,
      GestureDetector(
        onTap: () => parentTapped = true,
        child: PrimaryAppButton(
          title: 'Save',
          isDisabled: true,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(PrimaryAppButton));

    expect(tapped, isFalse);
    expect(parentTapped, isTrue);
  });

  testWidgets('every app button is the one standard height', (
    WidgetTester tester,
  ) async {
    // Whatever the title style, icon or loading state: the height used to
    // follow the text and each screen's padding, from 38 to 62px.
    const Gradient gradient = LinearGradient(
      colors: <Color>[Colors.green, Colors.blue],
    );
    final List<Widget> buttons = <Widget>[
      PrimaryAppButton(title: 'Save', onTap: () {}),
      PrimaryAppButton(title: 'Save', isLoading: true, onTap: () {}),
      PrimaryAppButton(
        title: 'Confirm',
        titleStyle: AppTextStyles.style20SemiBold,
        onTap: () {},
      ),
      PrimaryAppButton(
        title: 'Add',
        titleStyle: AppTextStyles.style14Medium,
        prefixIcon: const SizedBox.square(dimension: 24),
        onTap: () {},
      ),
      UnPrimaryAppButton(title: 'Reset', onTap: () {}),
      UnPrimaryAppButton(title: 'Reset', isLoading: true, onTap: () {}),
      PrimaryButton(title: 'Track', onTap: () {}),
      PrimaryButton(title: 'Track', isLoading: true, onTap: () {}),
      PrimaryGradientAppButton(title: 'Login', buttonGradient: gradient),
      UnPrimaryGradientAppButton(title: 'Guest', buttonGradient: gradient),
      UnPrimaryGradientAppButton(
        title: 'Guest',
        isLoading: true,
        buttonGradient: gradient,
      ),
    ];

    for (final Widget button in buttons) {
      await pumpCategoriesWidget(tester, Center(child: button));
      expect(
        tester.getSize(find.byWidget(button)).height,
        PrimaryAppButton.height,
        reason: '$button',
      );
    }
  });

  testWidgets('the label keeps the theme font', (WidgetTester tester) async {
    // The button's Material replaces the ambient text style instead of
    // merging, so a style without a family would fall back to the system font.
    await pumpCategoriesWidget(
      tester,
      PrimaryAppButton(title: 'Save', onTap: () {}),
    );

    final RenderParagraph label = tester.renderObject(find.text('Save'));
    expect(label.text.style!.fontFamily, FontFamily.cairo);
  });
}
