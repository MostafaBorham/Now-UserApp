import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_all_stores_section_view.dart';

import '../helpers/categories_test_harness.dart';








void main() {
  setUpAll(initCategoriesTestLocalization);


  StoreModel feedStore({required int id, required String name}) => StoreModel(
    id: id,
    name: <String, dynamic>{'en': name, 'ar': name},
    logoUrl: 'http://x/logo.png',
    coverUrl: 'http://x/cover.png',
    rating: 5.0,
    ratingCount: 2,
    deliveryFee: 12.0,
    deliveryTime: '15-25',
    distance: 2.5,
    isFavorite: false,
  );

  Future<void> pumpSection(
    WidgetTester tester, {
    required List<StoreModel> stores,
    List<CategoryModel> categories = const <CategoryModel>[],
    List<StoreModel> categoryStores = const <StoreModel>[],
  }) => pumpCategoriesWidget(
    tester,


    SingleChildScrollView(child: HomeAllStoresSectionView(stores: stores)),
    overrides: <Override>[
      overrideAppCategories(
        AsyncValue<PaginationModel<CategoryModel>>.data(
          pageOf<CategoryModel>(categories),
        ),
      ),
      overrideCategoryStores(
        AsyncValue<PaginationModel<StoreModel>>.data(
          pageOf<StoreModel>(categoryStores),
        ),
      ),
    ],
  );

  testWidgets('the All tab lists the stores the feed sent', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      stores: <StoreModel>[
        feedStore(id: 1, name: 'API Test Vendor'),
        feedStore(id: 3, name: 'Al-Nour Store'),
      ],
    );

    expect(find.byType(StoreCardView), findsNWidgets(2));
    expect(find.text('API Test Vendor'), findsOneWidget);
    expect(find.text('Al-Nour Store'), findsOneWidget);
  });

  testWidgets('caps the All tab at the handful the category tabs show', (
    WidgetTester tester,
  ) async {

    await pumpSection(
      tester,
      stores: List<StoreModel>.generate(
        HomeStoresListView.itemCount + 3,
        (int i) => feedStore(id: i, name: 'Store $i'),
      ),
    );

    expect(
      find.byType(StoreCardView),
      findsNWidgets(HomeStoresListView.itemCount),
    );
  });

  testWidgets('an empty all_stores section shows the no-results widget', (
    WidgetTester tester,
  ) async {

    await pumpSection(tester, stores: const <StoreModel>[]);

    expect(find.byType(NoResultsWidget), findsOneWidget);
    expect(find.byType(StoreCardView), findsNothing);
  });

  testWidgets('a category tab lists that category\'s stores, not the feed\'s', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      stores: <StoreModel>[feedStore(id: 1, name: 'From The Feed')],
      categories: <CategoryModel>[sampleCategory(en: 'Food')],
      categoryStores: <StoreModel>[
        feedStore(id: 9, name: 'From The Category'),
      ],
    );

    await tester.tap(find.text('Food'));
    await tester.pump();

    expect(find.text('From The Category'), findsOneWidget);
    expect(find.text('From The Feed'), findsNothing);
  });
}
