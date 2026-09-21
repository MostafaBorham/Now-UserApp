import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/all_stores/stores_search_filter_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/all_stores/stores_list_view.dart';

import '../../../helpers/categories_test_harness.dart';

/// A store tab only queries when it is the selected one; every other tab stays
/// a skeleton. That decision is made on the **category id**, not on the whole
/// `CategoryModel`.
///
/// `CategoryModel` is `Equatable` over all of its fields, so when the selection
/// was held as a model, a refetched categories list carrying any unrelated
/// change (`products_count`, `updated_at`, …) matched nothing: the tab bar fell
/// back to "All" while the filter still named the old category, and every tab —
/// "All" included — failed its own check and sat on the shimmer for good.
///
/// Never `pumpAndSettle` these — see the harness note (images animate forever).
void main() {
  setUpAll(initCategoriesTestLocalization);

  /// The category as the tab was built from it.
  CategoryModel food() =>
      const CategoryModel(id: 2, slug: 'food', name: {'en': 'Food', 'ar': 'طعام'});

  /// The same category as a later fetch returns it: same id, but the server has
  /// moved fields the shopper never sees.
  CategoryModel foodRefetched() => const CategoryModel(
    id: 2,
    slug: 'food',
    name: {'en': 'Food', 'ar': 'طعام'},
    productsCount: 87,
    updatedAt: '2026-09-21T10:00:00Z',
  );

  Future<void> pumpTab(
    WidgetTester tester,
    CategoryModel? category, {
    required int? selectedCategoryId,
  }) => pumpCategoriesWidget(
    tester,
    SizedBox(height: 600, child: StoresListView(category: category)),
    overrides: <Override>[
      storesSearchFilterProvider.overrideWith(
        (Ref ref) => StoresSearchFilterNotifier()
          ..setCategory(selectedCategoryId),
      ),
      overrideAllStores(
        AsyncValue<PaginationModel<StoreModel>>.data(
          pageOf<StoreModel>(<StoreModel>[
            sampleStore(id: 9, en: 'Al-Nour Store'),
          ]),
        ),
      ),
    ],
  );

  testWidgets('the selected tab lists its stores', (WidgetTester tester) async {
    await pumpTab(tester, food(), selectedCategoryId: 2);

    expect(find.text('Al-Nour Store'), findsOneWidget);
  });

  testWidgets('an unselected tab stays a skeleton', (
    WidgetTester tester,
  ) async {
    await pumpTab(tester, food(), selectedCategoryId: 7);

    // Placeholder cards render, but none of them carries a store.
    expect(find.byType(StoreCardView), findsWidgets);
    expect(find.text('Al-Nour Store'), findsNothing);
  });

  test('the refetched category is the same category but not the same model', () {
    // The premise of the next test, asserted so it cannot rot: these two carry
    // the same id and differ only in fields the shopper never sees, and that is
    // enough to make them unequal. Matching a selection on the model is what
    // used to strand every tab on its shimmer.
    expect(food().id, foodRefetched().id);
    expect(food(), isNot(foodRefetched()));
  });

  testWidgets('a refetched category with unrelated fields changed stays '
      'selected', (WidgetTester tester) async {
    await pumpTab(tester, foodRefetched(), selectedCategoryId: 2);

    expect(find.text('Al-Nour Store'), findsOneWidget);
  });

  testWidgets('the All tab is selected when nothing is picked', (
    WidgetTester tester,
  ) async {
    await pumpTab(tester, null, selectedCategoryId: null);

    expect(find.text('Al-Nour Store'), findsOneWidget);
  });
}
