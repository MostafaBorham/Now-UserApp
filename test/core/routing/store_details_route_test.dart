import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/routing/app_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

/// The store id must live in the route's path, not in `extra`.
///
/// go_router re-parses the route whenever the `Router` element is rebuilt —
/// hot reload, DevTools "Select Widget Mode", OS state restoration — and with
/// no `extraCodec` it puts `extra` through JSON, silently dropping anything
/// JSON cannot encode (a record, a model object). The URI always survives that
/// round trip, so anything the screen cannot work without belongs in the path.
void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  test('the store id is part of the URL', () {
    expect(
      AppRouter.router.namedLocation(
        AppRoutes.storeDetailsScreen,
        pathParameters: <String, String>{'id': '7'},
      ),
      '/store-details/7',
    );
  });

  test('two stores get two distinct locations', () {
    String locationFor(String id) => AppRouter.router.namedLocation(
      AppRoutes.storeDetailsScreen,
      pathParameters: <String, String>{'id': id},
    );

    expect(locationFor('7'), isNot(locationFor('8')));
  });

  test('the route cannot be built without an id', () {
    // Guards the old shape coming back: a pathless `/store-details` used to
    // resolve fine and leave the screen to invent an id.
    expect(
      () => AppRouter.router.namedLocation(AppRoutes.storeDetailsScreen),
      throwsA(anything),
    );
  });
}
