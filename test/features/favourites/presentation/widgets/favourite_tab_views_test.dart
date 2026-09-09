import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/empty_favourites_widget.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_store_tab_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

import '../../../../helpers/favourites_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  // The category chip row is the app-category list; keep it empty (only the
  // "All" tab) unless a test overrides it. With no other tab there is no
  // sibling list view rendering its unselected-tab shimmer, so what the tests
  // below find belongs to the "All" tab alone.
  final Override noChips = overrideAppCategories(
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
        ],
      );

      expect(find.byType(AppShimmer), findsWidgets);
      // A placeholder card renders ProductItem3View's own dummy product, so the
      // fixture's name — not the card type — is what marks "loaded".
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

      expect(find.byType(ProductItem3View), findsWidgets);
      expect(find.text('Pizza'), findsOneWidget);
    });

    testWidgets('an empty page shows the empty-favourites widget',
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

      expect(find.byType(EmptyFavouritesWidget), findsOneWidget);
      expect(find.byType(ProductItem3View), findsNothing);
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
    testWidgets('a loaded page renders store cards',
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

      // StoreCardView overflows under the fixed-width test font; drain those.
      for (dynamic ex = tester.takeException();
          ex != null;
          ex = tester.takeException()) {
        expect(ex.toString(), contains('overflow'));
      }

      expect(find.byType(StoreCardView), findsWidgets);
      expect(find.text('Corner Shop'), findsWidgets);
    });
  });

  group('FavouritesTabView filters', () {
    testWidgets('typing in the search field applies a debounced search filter',
        (WidgetTester tester) async {
      // Every query the visible list view asks for, in order.
      final List<List<Object?>> queries = <List<Object?>>[];
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(<ProductModel>[sampleProduct()]),
            ),
            onQuery: (int? categoryId, String? searchKey) =>
                queries.add(<Object?>[categoryId, searchKey]),
          ),
          noChips,
        ],
      );

      // The unfiltered "All" query the tab opens on.
      expect(queries, <List<Object?>>[
        <Object?>[null, null],
      ]);
      queries.clear();

      await tester.enterText(find.byType(TextField), 'shoes');
      // Nothing before the debounce window elapses.
      await tester.pump(const Duration(milliseconds: 500));
      expect(queries, isEmpty);
      await tester.pump(const Duration(seconds: 1));

      expect(queries, hasLength(1));
      expect(queries.single, <Object?>[null, 'shoes']);
    });

    testWidgets('selecting a category tab queries its id',
        (WidgetTester tester) async {
      final List<List<Object?>> queries = <List<Object?>>[];
      await pumpCategoriesWidget(
        tester,
        const FavouriteProductTabView(),
        overrides: <Override>[
          overrideFavouriteProducts(
            AsyncValue<PaginationModel<ProductModel>>.data(
              pageOf<ProductModel>(<ProductModel>[sampleProduct()]),
            ),
            onQuery: (int? categoryId, String? searchKey) =>
                queries.add(<Object?>[categoryId, searchKey]),
          ),
          overrideAppCategories(
            AsyncValue<PaginationModel<CategoryModel>>.data(
              pageOf<CategoryModel>(<CategoryModel>[
                sampleCategory(id: 7, en: 'Food'),
              ]),
            ),
          ),
        ],
      );

      expect(find.text('all'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      queries.clear();

      await tester.tap(find.text('Food'));
      await tester.pump(); // start the tab transition
      await tester.pump(const Duration(milliseconds: 500)); // finish it

      // The Food tab is now the selected one, so it — and only it — queries.
      expect(queries, <List<Object?>>[
        <Object?>[7, null],
      ]);
    });
  });
}
