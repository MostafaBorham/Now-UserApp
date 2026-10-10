import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/fonts.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

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

  testWidgets('loading keeps the button height', (WidgetTester tester) async {
    // The spinner is shorter than the label; swapping one for the other
    // instead of stacking them shrinks the button by 6px mid-tap.
    Future<double> heightWhen({required bool isLoading}) async {
      await pumpCategoriesWidget(
        tester,
        PrimaryAppButton(title: 'Save', isLoading: isLoading, onTap: () {}),
      );
      return tester.getSize(find.byType(PrimaryAppButton)).height;
    }

    final double idle = await heightWhen(isLoading: false);
    expect(await heightWhen(isLoading: true), idle);
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
