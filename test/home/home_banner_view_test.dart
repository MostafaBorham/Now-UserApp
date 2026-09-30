import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_banner_view.dart';

import '../helpers/categories_test_harness.dart';

/// A feed promo banner opens what it links to, by the slug the feed sends.
void main() {
  setUpAll(initCategoriesTestLocalization);

  final List<RouteBase> destinations = <RouteBase>[
    GoRoute(
      name: AppRoutes.productDetailsScreen,
      path: '/${AppRoutes.productDetailsScreen}',
      builder: (BuildContext context, GoRouterState state) =>
          Scaffold(body: Text('product:${state.extra}')),
    ),
    GoRoute(
      name: AppRoutes.categoryDetailsScreen,
      path: '/${AppRoutes.categoryDetailsScreen}/:slug',
      builder: (BuildContext context, GoRouterState state) =>
          Scaffold(body: Text('category:${state.pathParameters['slug']}')),
    ),
  ];

  Future<void> tapBanner(WidgetTester tester, Map<String, dynamic> json) async {
    await pumpCategoriesScreen(
      tester,
      Scaffold(
        body: SizedBox(
          height: 120,
          child: HomeBannerView(banner: BannerModel.fromJson(json)),
        ),
      ),
      destinationRoutes: destinations,
    );
    await tester.tap(find.byType(HomeBannerView));
    await tester.pumpAndSettle();
  }

  testWidgets('a product banner opens product details by its slug', (
    WidgetTester tester,
  ) async {
    await tapBanner(tester, <String, dynamic>{
      'slot': 'footer',
      'id': 1815,
      'image_en': 'http://x/en.jpg',
      'link_type': 'product',
      'product_id': 42,
      'product_slug': 'cool-thing',
      'main_category_id': null,
      'category_slug': null,
    });

    expect(find.text('product:cool-thing'), findsOneWidget);
  });

  testWidgets('a category banner opens category details by its slug', (
    WidgetTester tester,
  ) async {
    await tapBanner(tester, <String, dynamic>{
      'slot': 'middle',
      'id': 1814,
      'image_en': 'http://x/en.jpg',
      'link_type': 'category',
      'product_id': null,
      'product_slug': null,
      'main_category_id': 1,
      'category_slug': 'electronics',
    });

    expect(find.text('category:electronics'), findsOneWidget);
  });
}
