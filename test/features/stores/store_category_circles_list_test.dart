import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';

import '../../helpers/categories_test_harness.dart';

/// The store screen's category chips name the store's own main categories,
/// not wherever its products are filed (other main categories, subcategories).
void main() {
  setUpAll(initCategoriesTestLocalization);

  CategoryModel category(int id, String name) =>
      CategoryModel(id: id, name: <String, dynamic>{'en': name, 'ar': name});

  Future<void> pumpStrip(WidgetTester tester, StoreModel store) =>
      pumpCategoriesWidget(
        tester,
        const StoreCategoryCirclesList(),
        overrides: <Override>[storeProvider.overrideWith((Ref ref) => store)],
      );

  testWidgets('shows only the main categories the store is assigned to', (
    WidgetTester tester,
  ) async {
    await pumpStrip(
      tester,
      StoreModel(
        id: 8,
        mainCategories: <CategoryModel>[category(1, 'Supermarket')],
        categories: <CategoryModel>[
          category(2, 'Electronics'),
          category(5, 'Mobiles & Accessories'),
        ],
      ),
    );

    expect(find.text('Supermarket'), findsOneWidget);
    expect(find.text('Electronics'), findsNothing);
    expect(find.text('Mobiles & Accessories'), findsNothing);
  });

  testWidgets('no assigned main category: the strip is hidden', (
    WidgetTester tester,
  ) async {
    await pumpStrip(
      tester,
      StoreModel(
        id: 8,
        categories: <CategoryModel>[category(2, 'Electronics')],
      ),
    );

    expect(find.text('Electronics'), findsNothing);
  });
}
