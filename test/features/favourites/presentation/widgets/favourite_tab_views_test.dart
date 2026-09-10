import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/providers/favourites_filter_provider.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_store_tab_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card2.dart';

import '../../../../helpers/favourites_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  // The chip row hits its own provider; keep it empty unless a test overrides.
  final Override noChips = overrideFavouriteCategories(
    const AsyncValue<List<FavouriteCategoryModel>>.data(
      <FavouriteCategoryModel>[],
    ),
  );

  // The tab bar reads the app categories over the network; stub it to an empty
  // page (only the "All" tab) so a test never hits the real repo — a test that
  // needs category tabs overrides it with its own list.
  final Override noCategoryTabs = overrideAppCategories(
    AsyncValue<PaginationModel<CategoryModel>>.data(
      pageOf<CategoryModel>(const <CategoryModel>[]),
    ),
  );

  group('FavouriteProductTabView states', () {
    testWidgets('first-page loading shows shimmer, no product data',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            const AsyncValue<PaginationModel<ProductModel>>.loading(),
          ),
          noChips,
          noCategoryTabs,
        ],
      );

      expect(find.byType(AppShimmer), findsWidgets);
      expect(find.text('Pizza'), findsNothing);
    });

    testWidgets('a loaded page renders product cards',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(<ProductModel>[sampleProduct(en: 'Pizza')]),
            ),
          ),
          noChips,
          noCategoryTabs,
        ],
      );

      // (A loaded card still shows an AppShimmer inside its image placeholder,
      // so the product name — not shimmer absence — is what marks "loaded".)
      expect(find.byType(ProductItemCard2), findsWidgets);
      expect(find.text('Pizza'), findsOneWidget);
    });

    testWidgets('an empty page shows the no-items widget',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(const <ProductModel>[]),
            ),
          ),
          noChips,
          noCategoryTabs,
        ],
      );

      expect(find.byType(NoResultsWidget), findsOneWidget);
      expect(find.byType(ProductItemCard2), findsNothing);
    });

    testWidgets('a failed first page shows the error widget',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.error(
              'serverConnectionFailed',
              StackTrace.empty,
            ),
          ),
          noChips,
          noCategoryTabs,
        ],
      );

      expect(find.byType(ServerConnectionErrorWidget), findsOneWidget);
    });
  });

  group('FavouriteStoreTabView', () {
    testWidgets('a loaded page renders store items',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        const FavouriteStoreTabView(),
        overrides: <Override>[
          overrideFavouriteStores(
            AsyncValue<PaginationModel<StoreModel>>.data(
              pageOf<StoreModel>(<StoreModel>[sampleStore(en: 'Corner Shop')]),
            ),
          ),
          noChips,
          noCategoryTabs,
        ],
      );

      // StoreItem overflows under the fixed-width test font; drain those.
      for (dynamic ex = tester.takeException();
          ex != null;
          ex = tester.takeException()) {
        expect(ex.toString(), contains('overflow'));
      }

      expect(find.byType(StoreItem), findsWidgets);
    });
  });

  group('FavouritesTabView filters', () {
    // Reads the live product-tab filter (search + selected category) the tab
    // view drives through favouritesFilterProvider — the single source both the
    // search field and the category tab bar write into.
    FavouritesFilter productFilter(WidgetTester tester) => ProviderScope
        .containerOf(tester.element(find.byType(FavouriteProductTabView)))
        .read(favouritesFilterProvider('product'));

    testWidgets('typing in the search field sets the search filter '
        'after the debounce', (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(<ProductModel>[sampleProduct()]),
            ),
          ),
          // Only the "All" tab; keeps this test about the search field alone.
          overrideAppCategories(
            AsyncValue<PaginationModel<CategoryModel>>.data(
              pageOf<CategoryModel>(const <CategoryModel>[]),
            ),
          ),
          noChips,
        ],
      );

      await tester.enterText(find.byType(TextField), 'shoes');
      // The search field debounces for one second — nothing before it elapses.
      expect(productFilter(tester).search, isEmpty);

      await tester.pump(const Duration(seconds: 1));

      expect(productFilter(tester).search, 'shoes');
    });

    testWidgets('selecting a category tab sets it as the filter category',
        (WidgetTester tester) async {
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(<ProductModel>[sampleProduct()]),
            ),
          ),
          // The tab bar labels come from the app categories, not the chip row.
          overrideAppCategories(
            AsyncValue<PaginationModel<CategoryModel>>.data(
              pageOf<CategoryModel>(<CategoryModel>[
                sampleCategory(id: 7, en: 'Food'),
              ]),
            ),
          ),
          noChips,
        ],
      );

      // "All" plus the one app-category tab.
      expect(find.text('all'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      // Starts on "All": no category selected.
      expect(productFilter(tester).category, isNull);

      await tester.tap(find.text('Food'));
      await tester.pump();

      expect(productFilter(tester).category?.id, 7);
    });
  });
}
