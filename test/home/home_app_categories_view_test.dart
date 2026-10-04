import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('one category is shown once and stays put (BUG-002)', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      HomeAppCategoriesView(categories: <CategoryModel>[sampleCategory()]),
    );
    expect(find.text('Food'), findsOneWidget);

    // Past the 3 s auto-slide interval: nothing moves, nothing repeats.
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('three categories are each shown once', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      HomeAppCategoriesView(categories: sampleCategories(3)),
    );
    for (int i = 0; i < 3; i++) {
      expect(find.text('Category $i'), findsOneWidget);
    }
  });
}
