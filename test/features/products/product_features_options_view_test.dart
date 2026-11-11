import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/product_features_options_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/product_features_sections.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_section_card/product_features_section_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_section_card/widgets/product_features_section_header.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sidebar/widgets/product_features_sidebar_item.dart';

import '../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  final Finder sectionsViewport = find.descendant(
    of: find.byType(ProductFeaturesSections),
    matching: find.byType(Scrollable),
  );

  Finder sidebarItem(int section) =>
      find.byType(ProductFeaturesSidebarItem).at(section);

  bool isSelected(WidgetTester tester, int section) => tester
      .widget<ProductFeaturesSidebarItem>(sidebarItem(section))
      .isSelected;

  double sectionGapFromTop(WidgetTester tester, int section) =>
      tester
          .getTopLeft(find.byType(ProductFeaturesSectionCard).at(section))
          .dy -
      tester.getTopLeft(sectionsViewport).dy;

  bool isCollapsed(WidgetTester tester, int section) => tester
      .widget<ProductFeaturesSectionCard>(
        find.byType(ProductFeaturesSectionCard).at(section),
      )
      .isCollapsed;

  Future<void> collapseSectionAndReturnToFirst(
    WidgetTester tester,
    int section,
  ) async {
    await tester.tap(sidebarItem(section));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ProductFeaturesSectionHeader).at(section));
    await tester.pumpAndSettle();
    await tester.tap(sidebarItem(0));
    await tester.pumpAndSettle();
    expect(isSelected(tester, 0), isTrue);
    expect(isCollapsed(tester, section), isTrue);
  }

  testWidgets('tapping a collapsed feature expands its section', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const ProductFeaturesOptionsView());
    await collapseSectionAndReturnToFirst(tester, 1);

    await tester.tap(sidebarItem(1));
    await tester.pumpAndSettle();

    expect(isCollapsed(tester, 1), isFalse);
    expect(sectionGapFromTop(tester, 1), 16);
  });

  testWidgets('a collapsed section scrolled to the top expands', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const ProductFeaturesOptionsView());
    await collapseSectionAndReturnToFirst(tester, 1);

    await tester.drag(sectionsViewport, const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(isSelected(tester, 1), isTrue);
    expect(isCollapsed(tester, 1), isFalse);
  });

  testWidgets('collapsing the section at the top keeps it collapsed', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const ProductFeaturesOptionsView());
    await tester.tap(find.byType(ProductFeaturesSectionHeader).at(0));
    await tester.pumpAndSettle();
    expect(isCollapsed(tester, 0), isTrue);

    await tester.drag(sectionsViewport, const Offset(0, -5));
    await tester.pumpAndSettle();

    expect(isSelected(tester, 0), isTrue);
    expect(isCollapsed(tester, 0), isTrue);
  });

  testWidgets('tapping a feature scrolls its section to the top', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const ProductFeaturesOptionsView());
    expect(sectionGapFromTop(tester, 0), 16);

    await tester.tap(sidebarItem(1));
    await tester.pumpAndSettle();

    expect(sectionGapFromTop(tester, 1), 16);
    expect(isSelected(tester, 1), isTrue);

    await tester.tap(sidebarItem(0));
    await tester.pumpAndSettle();

    expect(sectionGapFromTop(tester, 0), 16);
    expect(isSelected(tester, 0), isTrue);
  });

  testWidgets('the tapped feature stays selected while scrolling to it', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const ProductFeaturesOptionsView());

    await tester.tap(sidebarItem(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(sectionGapFromTop(tester, 1), greaterThan(16));
    expect(isSelected(tester, 1), isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('scrolling a section to the top selects its feature', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const ProductFeaturesOptionsView());

    await tester.drag(sectionsViewport, const Offset(0, -20));
    await tester.pumpAndSettle();
    expect(isSelected(tester, 0), isTrue);

    await tester.drag(sectionsViewport, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(sectionGapFromTop(tester, 1), 16);
    expect(isSelected(tester, 1), isTrue);

    await tester.drag(sectionsViewport, const Offset(0, 1000));
    await tester.pumpAndSettle();
    expect(sectionGapFromTop(tester, 0), 16);
    expect(isSelected(tester, 0), isTrue);
  });
}
