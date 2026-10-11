import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/connectivity_controller.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/main/presentation/screens/main_screen.dart';

import '../../helpers/categories_test_harness.dart';

class _EmptyFeed extends GetHomeSectionsViewModel {
  _EmptyFeed() {
    state = const AsyncValue<List<HomeSectionModel>>.data(
      <HomeSectionModel>[],
    );
  }

  @override
  Future<void> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {}
}

// BUG-005: `/main` is the only route, so back on any tab closed the app.
void main() {
  setUpAll(() async {
    await initCategoriesTestLocalization();
    await SharedPrefManager.init();
  });

  testWidgets('back on another tab returns to Home', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      const MainScreen(),
      overrides: <Override>[
        getHomeSectionsProvider.overrideWith((Ref ref) => _EmptyFeed()),
        isConnectedProvider.overrideWith((Ref ref) => Stream<bool>.value(true)),
        mainTabIndexProvider.overrideWith((Ref ref) => 4),
      ],
    );
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(MainScreen)),
    );

    // `true`: the app handled it, so it did not close.
    expect(await tester.binding.handlePopRoute(), isTrue);
    expect(container.read(mainTabIndexProvider), 0);
  });
}
