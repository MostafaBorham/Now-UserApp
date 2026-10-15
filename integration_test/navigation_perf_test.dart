import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:nowdelivery_user_app/main.dart' as app;

/// Screen-change frame-time benchmark: pushes and pops the screens customers
/// open most, from Home, and records the frames of each transition.
///
/// Run like home_perf_test.dart, on a real device in profile mode:
///
///     PERF_LABEL=<label> flutter drive --profile --no-dds --keep-app-running \
///       --driver=test_driver/perf_driver.dart \
///       --target=integration_test/navigation_perf_test.dart -d <device>
///
/// Each scenario is one push, a pause on the new screen, one pop and a pause
/// back on Home, timed as a whole. A transition runs ~450 ms on Android, so a
/// scenario's worst build / raster frames are the transition's own (the pages
/// are idle by then). Results land in `build/perf/<label>/nav_<screen>.json`.
void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('navigation performance', (WidgetTester tester) async {
    final FlutterExceptionHandler? reportToTest = FlutterError.onError;
    app.main();
    FlutterError.onError = reportToTest;

    final Finder home = find.byType(HomeView);
    final Finder guest = find.byType(UnPrimaryGradientAppButton);
    await _pumpUntil(tester, () => _found(home) || _found(guest));
    if (!_found(home)) {
      await tester.tap(guest);
      await _pumpUntil(tester, () => _found(home));
    }
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(home),
    );
    await _pumpUntil(
      tester,
      () => container.read(getHomeSectionsProvider).hasValue,
    );
    await _wait(const Duration(seconds: 15));

    final List<HomeSectionModel> sections = container
        .read(getHomeSectionsProvider)
        .requireValue;
    final ProductModel? product = sections
        .expand((HomeSectionModel s) => s.products)
        .where((ProductModel p) => (p.slug ?? '').isNotEmpty)
        .firstOrNull;
    final StoreModel? store = sections
        .expand((HomeSectionModel s) => s.stores)
        .where((StoreModel s) => s.id != null)
        .firstOrNull;

    Future<void> roundTrip(String name, Future<Object?> Function() push) =>
        binding.watchPerformance(() async {
          _step(name);
          // Not awaited: the push future completes on pop.
          push();
          await _wait(const Duration(seconds: 3));
          AppRouter.router.pop();
          await _wait(const Duration(seconds: 2));
          await tester.pump();
        }, reportKey: 'nav_$name');

    // Control: Home on its own for as long as a round trip, so its own
    // animations (carousels) can be told apart from the transitions.
    await binding.watchPerformance(() async {
      _step('idle_home');
      await _wait(const Duration(seconds: 5));
      await tester.pump();
    }, reportKey: 'nav_idle_home');

    if (product != null) {
      await roundTrip(
        'product_details',
        () => AppRouter.router.pushNamed(
          AppRoutes.productDetailsScreen,
          extra: product.slug,
        ),
      );
    }
    if (store != null) {
      await roundTrip(
        'store_details',
        () => AppRouter.router.pushNamed(
          AppRoutes.storeDetailsScreen,
          pathParameters: <String, String>{'id': '${store.id}'},
        ),
      );
    }
    await roundTrip(
      'search',
      () => AppRouter.router.pushNamed(AppRoutes.searchScreen),
    );
    await roundTrip(
      'all_stores',
      () => AppRouter.router.pushNamed(AppRoutes.allStoresScreen),
    );
  });
}

void _step(String scenario) => debugPrint('nav_perf: $scenario');

bool _found(Finder finder) => finder.evaluate().isNotEmpty;

Future<void> _wait(Duration duration) => Future<void>.delayed(duration);

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() done, {
  Duration timeout = const Duration(seconds: 90),
}) async {
  final Stopwatch clock = Stopwatch()..start();
  while (!done()) {
    if (clock.elapsed > timeout) {
      throw TestFailure('Home did not load within $timeout');
    }
    await _wait(const Duration(milliseconds: 200));
    await tester.pump();
  }
}
