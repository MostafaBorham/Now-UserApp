import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_banner.dart';

import '../../../../helpers/categories_test_harness.dart';

// BUG-023: a store banner linked to a category did nothing — it waited for a
// `category_slug` the store payload never fills.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<void> tapBanner(WidgetTester tester, BannerModel banner) async {
    await pumpCategoriesScreen(
      tester,
      Scaffold(body: StoreDetailsBanner(banner: banner)),
      overrides: <Override>[
        storeProvider.overrideWithValue(const StoreModel(id: 5)),
      ],
      destinationRoutes: <RouteBase>[
        GoRoute(
          name: AppRoutes.viewStoreCategoryProductsScreen,
          path: '/store-category/:storeId/:categoryId',
          builder: (BuildContext context, GoRouterState state) => Text(
            'store ${state.pathParameters['storeId']} '
            'category ${state.pathParameters['categoryId']}',
          ),
        ),
      ],
    );

    await tester.tap(find.byType(StoreDetailsBanner));
    await tester.pumpAndSettle();
  }

  testWidgets("a category banner opens this store's category", (
    WidgetTester tester,
  ) async {
    await tapBanner(
      tester,
      const BannerModel(linkType: 'category', mainCategoryId: 12),
    );

    expect(find.text('store 5 category 12'), findsOneWidget);
  });

  testWidgets('a subcategory banner opens that exact subcategory', (
    WidgetTester tester,
  ) async {
    await tapBanner(
      tester,
      const BannerModel(
        linkType: 'category',
        mainCategoryId: 12,
        categoryId: 34,
      ),
    );

    expect(find.text('store 5 category 34'), findsOneWidget);
  });
}
