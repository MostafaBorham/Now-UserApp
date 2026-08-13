import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
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
        ],
      );

      expect(find.byType(NoItemsWidget), findsOneWidget);
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
    testWidgets('typing in the search field applies a debounced search filter',
        (WidgetTester tester) async {
      final List<List<Object?>> calls = <List<Object?>>[];
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(<ProductModel>[sampleProduct()]),
            ),
            onApplyFilters: (String? s, List<int> c, String? sort) =>
                calls.add(<Object?>[s, c, sort]),
          ),
          noChips,
        ],
      );

      await tester.enterText(find.byType(TextField), 'shoes');
      // Nothing before the debounce window elapses.
      expect(calls, isEmpty);
      await tester.pump(const Duration(milliseconds: 400));

      expect(calls, hasLength(1));
      expect(calls.single[0], 'shoes');
      expect(calls.single[1], const <int>[]);
      expect(calls.single[2], 'recent'); // default sort
    });

    testWidgets('selecting a category chip applies its id',
        (WidgetTester tester) async {
      final List<List<Object?>> calls = <List<Object?>>[];
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(<ProductModel>[sampleProduct()]),
            ),
            onApplyFilters: (String? s, List<int> c, String? sort) =>
                calls.add(<Object?>[s, c, sort]),
          ),
          overrideFavouriteCategories(
            AsyncValue<List<FavouriteCategoryModel>>.data(
              <FavouriteCategoryModel>[
                sampleFavouriteCategory(id: 7, en: 'Food', count: 3),
              ],
            ),
          ),
        ],
      );

      expect(find.text('all'), findsOneWidget);
      expect(find.text('Food (3)'), findsOneWidget);

      await tester.tap(find.text('Food (3)'));
      await tester.pump();

      expect(calls, hasLength(1));
      expect(calls.single[1], const <int>[7]);
    });
  });
}
