import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_never_miss_offers_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_item.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

import '../helpers/categories_test_harness.dart';

/// A feed frozen in [value]; a reload only counts.
class _FakeFeed extends GetHomeSectionsViewModel {
  _FakeFeed(AsyncValue<List<HomeSectionModel>> value) {
    state = value;
  }

  int reloads = 0;

  @override
  Future<void> reload() async => reloads++;
}

void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<_FakeFeed> pumpScreen(
    WidgetTester tester,
    AsyncValue<List<HomeSectionModel>> feed,
  ) async {
    final _FakeFeed fake = _FakeFeed(feed);
    await pumpCategoriesWidget(
      tester,
      const HomeNeverMissOffersScreen(),
      useScaffold: false,
      overrides: <Override>[
        getHomeSectionsProvider.overrideWith((Ref ref) => fake),
      ],
    );
    await tester.pump(const Duration(seconds: 3));
    return fake;
  }

  testWidgets('a failed refresh keeps the loaded offers, no error', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      AsyncValue<List<HomeSectionModel>>.error(
        'boom',
        StackTrace.empty,
      ).copyWithPrevious(
        const AsyncValue<List<HomeSectionModel>>.data(<HomeSectionModel>[
          HomeSectionModel(
            type: 'flash_offers',
            products: <ProductModel>[
              ProductModel(id: 1, slug: 'a'),
              ProductModel(id: 2, slug: 'b'),
            ],
          ),
        ]),
      ),
    );

    expect(find.byType(HomeNeverMissOffersItem), findsNWidgets(2));
    expect(find.byType(ServerConnectionErrorWidget), findsNothing);
  });

  testWidgets('an error with no offers retries the feed', (
    WidgetTester tester,
  ) async {
    final _FakeFeed feed = await pumpScreen(
      tester,
      AsyncValue<List<HomeSectionModel>>.error('boom', StackTrace.empty),
    );

    expect(find.byType(HomeNeverMissOffersItem), findsNothing);
    await tester.tap(find.text(LangKeys.retryKey));
    expect(feed.reloads, 1);
  });
}
