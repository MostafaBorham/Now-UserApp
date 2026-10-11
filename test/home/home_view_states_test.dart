import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/connectivity_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_most_popular_brands_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';

import '../helpers/categories_test_harness.dart';

/// A feed frozen in [value]; a reload only counts.
class _FakeFeed extends GetHomeSectionsViewModel {
  _FakeFeed(AsyncValue<List<HomeSectionModel>> value) {
    state = value;
  }

  int loads = 0;

  @override
  Future<void> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async => loads++;
}

/// Featured stores answering every page with [stores]; counts the fetches.
class _FakeFeatured extends GetFeaturedStoresViewModel {
  _FakeFeatured(this.stores) {
    state = AsyncValue<PaginationModel<StoreModel>>.data(
      pageOf<StoreModel>(stores),
    );
  }

  final List<StoreModel> stores;
  int fetches = 0;

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(
    int page,
  ) async {
    fetches++;
    return Right<Failure, PaginationModel<StoreModel>>(
      pageOf<StoreModel>(stores),
    );
  }
}

/// Home's own states (BUG-004, QA V2): a failed first load, an empty feed, and
/// a loaded one.
void main() {
  setUpAll(() async {
    await initCategoriesTestLocalization();
    await SharedPrefManager.init();
  });

  Future<({_FakeFeed feed, _FakeFeatured featured})> pumpHome(
    WidgetTester tester,
    AsyncValue<List<HomeSectionModel>> feed, {
    List<StoreModel> featured = const <StoreModel>[],
  }) async {
    final _FakeFeed fake = _FakeFeed(feed);
    final _FakeFeatured fakeFeatured = _FakeFeatured(featured);
    await pumpCategoriesWidget(
      tester,
      const HomeView(),
      overrides: <Override>[
        getHomeSectionsProvider.overrideWith((Ref ref) => fake),
        getFeaturedStoresProvider.overrideWith((Ref ref) => fakeFeatured),
        isConnectedProvider.overrideWith((Ref ref) => Stream<bool>.value(true)),
      ],
    );
    await tester.pump(const Duration(seconds: 3));
    return (feed: fake, featured: fakeFeatured);
  }

  testWidgets('a failed first load is one full error, no endless carousel', (
    WidgetTester tester,
  ) async {
    final (:_FakeFeed feed, :_FakeFeatured featured) = await pumpHome(
      tester,
      AsyncValue<List<HomeSectionModel>>.error('boom', StackTrace.empty),
    );

    expect(find.byType(ServerConnectionErrorWidget), findsOneWidget);
    expect(find.byType(HomeAppCategoriesView), findsNothing);
    expect(find.byType(HomeMostPopularBrandsView), findsNothing);

    final int before = feed.loads;
    await tester.ensureVisible(find.text(LangKeys.retryKey));
    await tester.pump();
    await tester.tap(find.text(LangKeys.retryKey));
    expect(feed.loads, before + 1);
    // Top Brands is retried with it (BUG-023, QA V2).
    expect(featured.fetches, 1);
  });

  testWidgets('an empty feed shows the empty state', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      const AsyncValue<List<HomeSectionModel>>.data(<HomeSectionModel>[]),
    );

    expect(find.byType(NoResultsWidget), findsOneWidget);
    expect(find.byType(ServerConnectionErrorWidget), findsNothing);
  });

  testWidgets('a feed with categories is not empty', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      AsyncValue<List<HomeSectionModel>>.data(<HomeSectionModel>[
        HomeSectionModel(
          type: 'categories',
          categories: <CategoryModel>[sampleCategory()],
        ),
      ]),
    );

    expect(find.byType(HomeAppCategoriesView), findsOneWidget);
    expect(find.byType(NoResultsWidget), findsNothing);
  });

  // BUG-007: the order used to be hardcoded, so the admin's was ignored.
  testWidgets('feed sections follow the feed order', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      AsyncValue<List<HomeSectionModel>>.data(<HomeSectionModel>[
        HomeSectionModel(
          id: 3,
          type: 'products_by_category',
          category: sampleCategory(),
          products: <ProductModel>[sampleProduct()],
        ),
        HomeSectionModel(
          id: 1,
          type: 'featured_stores',
          stores: <StoreModel>[sampleStore()],
        ),
        HomeSectionModel(
          id: 2,
          type: 'nearby_stores',
          stores: <StoreModel>[sampleStore()],
        ),
      ]),
    );

    final List<Key?> keys = tester
        .widget<HomeFeedList>(find.byType(HomeFeedList))
        .sections
        .map((HomeFeedSection s) => s.key)
        .toList();
    expect(
      keys.where((Key? k) => k is ValueKey<Object> && k.value is int),
      <Key>[
        const ValueKey<Object>(3),
        const ValueKey<Object>(1),
        const ValueKey<Object>(2),
      ],
    );
  });
}
