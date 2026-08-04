import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card_shimmer.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  Widget boxed(Widget child) =>
      Center(child: SizedBox(width: 150, height: 180, child: child));

  group('CategoryCard', () {
    testWidgets('renders the English localized name', (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        boxed(CategoryCard(category: sampleCategory(en: 'Food', ar: 'طعام'))),
      );

      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('hides the discount badge when hasOffer is false',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        boxed(
          CategoryCard(
            category: const CategoryModel(
              name: <String, dynamic>{'en': 'Food'},
              descendantsCount: 10,
            ),
          ),
        ),
      );

      // Card is mounted (guards against a false pass on an empty tree)...
      expect(find.text('Food'), findsOneWidget);
      // ...and the badge text ("<n> % discount") is absent with the offer off.
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('shows the discount badge when hasOffer is true',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        boxed(
          CategoryCard(
            hasOffer: true,
            category: const CategoryModel(
              name: <String, dynamic>{'en': 'Food'},
              descendantsCount: 10,
            ),
          ),
        ),
      );

      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('invokes onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await pumpCategoriesWidget(
        tester,
        boxed(
          CategoryCard(
            category: sampleCategory(en: 'Food'),
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Food'));
      expect(tapped, isTrue);
    });
  });

  group('CategoryCardShimmer', () {
    testWidgets('builds without error', (WidgetTester tester) async {
      await pumpCategoriesWidget(tester, boxed(const CategoryCardShimmer()));
      expect(find.byType(CategoryCardShimmer), findsOneWidget);
    });
  });
}
