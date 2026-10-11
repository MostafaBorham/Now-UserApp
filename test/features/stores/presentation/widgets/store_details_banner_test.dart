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

  testWidgets("a category banner opens this store's category", (
    WidgetTester tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      const Scaffold(
        body: StoreDetailsBanner(
          banner: BannerModel(linkType: 'category', mainCategoryId: 12),
        ),
      ),
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

    expect(find.text('store 5 category 12'), findsOneWidget);
  });
}
