import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/routing/app_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

/// The store and the category both have to survive a route re-parse, so both
/// live in the URL — the same rule `store_details_route_test.dart` pins for the
/// store details screen.
///
/// This route used to take the whole `CategoryModel` through `extra`, which
/// go_router puts through JSON with no `extraCodec` and silently drops, and it
/// carried no store id at all.
void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  String locationFor(String storeId, String categoryId) =>
      AppRouter.router.namedLocation(
        AppRoutes.viewStoreCategoryProductsScreen,
        pathParameters: <String, String>{
          'storeId': storeId,
          'categoryId': categoryId,
        },
      );

  test('both ids are part of the URL', () {
    expect(locationFor('7', '42'), '/store-category-products/7/42');
  });

  test('the same category under two stores gets two distinct locations', () {
    // The whole point of the fix: the category alone no longer identifies the
    // screen, because it used to list that category across every store.
    expect(locationFor('7', '42'), isNot(locationFor('8', '42')));
  });

  test('two categories in one store get two distinct locations', () {
    expect(locationFor('7', '42'), isNot(locationFor('7', '43')));
  });

  test('the route cannot be built without both ids', () {
    expect(
      () => AppRouter.router.namedLocation(
        AppRoutes.viewStoreCategoryProductsScreen,
      ),
      throwsA(anything),
    );
    expect(
      () => AppRouter.router.namedLocation(
        AppRoutes.viewStoreCategoryProductsScreen,
        pathParameters: <String, String>{'storeId': '7'},
      ),
      throwsA(anything),
    );
  });
}
