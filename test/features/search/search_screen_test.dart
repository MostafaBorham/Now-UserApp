import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/core/data/repo/recent_keywords_repo.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_products_vm.dart';
import 'package:nowdelivery_user_app/features/search/presentation/screens/search_screen.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_results_view.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/recent_search_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_all_stores_vm.dart';

import '../../helpers/categories_test_harness.dart';

/// `/api/v1/products` answers any term under three characters with an empty
/// page, so the screen must not search those at all — it used to, and showed
/// "No results" for "tv".
void main() {
  setUpAll(initCategoriesTestLocalization);

  final List<String> searched = <String>[];
  final List<String?> searchedStores = <String?>[];

  // What the fakes answer with; reset per test.
  List<ProductModel> productResults = <ProductModel>[];
  List<StoreModel> storeResults = <StoreModel>[];

  /// Labels render as their raw keys on the test surface and overflow their
  /// rows; only layout overflow is tolerated.
  void ignoreOverflow(WidgetTester tester) {
    for (
      Object? ex = tester.takeException();
      ex != null;
      ex = tester.takeException()
    ) {
      expect(ex.toString(), contains('overflow'));
    }
  }

  Future<void> pumpSearch(WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const SearchScreen(),
      overrides: <Override>[
        overrideAppCategories(
          AsyncValue<PaginationModel<CategoryModel>>.data(
            pageOf<CategoryModel>(<CategoryModel>[]),
          ),
        ),
        // Never loaded, so it never touches Hive.
        recentSearchProvider.overrideWith(
          (Ref ref) => RecentKeywordsViewModel(
            RecentKeywordsRepo(
              boxName: 'unused',
              key: 'unused',
              maxKeywords: 1,
            ),
          ),
        ),
        getProductsProvider.overrideWith((Ref ref, String search) {
          searched.add(search);
          return _FakeProductsVM(search, productResults);
        }),
        getAllStoresProvider.overrideWith((Ref ref, AllStoresArgs args) {
          searchedStores.add(args.searchKey);
          return _FakeStoresVM(args, storeResults);
        }),
      ],
    );
    ignoreOverflow(tester);
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    // Past the field's 1 s debounce.
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();
    ignoreOverflow(tester);
  }

  setUp(() {
    searched.clear();
    searchedStores.clear();
    productResults = <ProductModel>[sampleProduct()];
    storeResults = <StoreModel>[];
  });

  testWidgets('a two-character term is not searched', (
    WidgetTester tester,
  ) async {
    await pumpSearch(tester);

    await type(tester, 'tv');

    expect(find.byType(SearchResultsView), findsNothing);
    expect(searched, isEmpty);
  });

  testWidgets('a three-character term is searched', (
    WidgetTester tester,
  ) async {
    await pumpSearch(tester);

    await type(tester, 'tvs');

    expect(find.byType(SearchResultsView), findsOneWidget);
    expect(searched, <String>['tvs']);
    expect(searchedStores, <String?>['tvs']);
  });

  testWidgets('shortening a term below three clears its results', (
    WidgetTester tester,
  ) async {
    await pumpSearch(tester);

    await type(tester, 'tvs');
    await type(tester, 'tv');

    expect(find.byType(SearchResultsView), findsNothing);
  });

  // A store's name matches no product, so the products-only search used to
  // answer «النور» with "No results" although the store exists.
  testWidgets('a term matching only a store shows that store', (
    WidgetTester tester,
  ) async {
    productResults = <ProductModel>[];
    storeResults = <StoreModel>[sampleStore(id: 15, en: 'Al-Nour Store')];
    await pumpSearch(tester);

    await type(tester, 'النور');

    expect(searchedStores, <String?>['النور']);
    expect(find.byType(StoreCardView), findsOneWidget);
    expect(find.text(LangKeys.noSearchMatchesKey), findsNothing);
  });

  testWidgets('no store and no product says nothing matched', (
    WidgetTester tester,
  ) async {
    productResults = <ProductModel>[];
    await pumpSearch(tester);

    await type(tester, 'zzz');

    expect(find.byType(StoreCardView), findsNothing);
    expect(find.text(LangKeys.noSearchMatchesKey), findsOneWidget);
  });
}

class _FakeStoresVM extends GetAllStoresViewModel {
  _FakeStoresVM(AllStoresArgs args, List<StoreModel> stores)
    : super(args: args) {
    state = AsyncValue<PaginationModel<StoreModel>>.data(
      pageOf<StoreModel>(stores),
    );
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}

class _FakeProductsVM extends GetProductsViewModel {
  _FakeProductsVM(String search, List<ProductModel> products)
    : super(search: search) {
    state = AsyncValue<PaginationModel<ProductModel>>.data(
      pageOf<ProductModel>(products),
    );
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}
