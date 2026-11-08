import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_products_vm.dart';
import 'package:nowdelivery_user_app/features/search/data/last_search_results_cache.dart';
import 'package:nowdelivery_user_app/features/search/presentation/screens/search2_screen.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_back_button.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_recent_search_section.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_placeholder_view.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_results_view.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_all_stores_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';

import '../../helpers/categories_test_harness.dart';

void main() {
  late Directory cacheDirectory;
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  setUpAll(() async {
    await initCategoriesTestLocalization();
    cacheDirectory = await Directory.systemTemp.createTemp(
      'search2_cache_test',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProvider,
          (_) async => cacheDirectory.path,
        );
    await HiveManager.init();
    await HiveManager.box(HiveBoxes.recentSearches).close();
    await Hive.openBox<dynamic>(HiveBoxes.recentSearches, bytes: Uint8List(0));
  });

  tearDownAll(() async {
    await Hive.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
    await cacheDirectory.delete(recursive: true);
  });

  setUp(
    () => HiveManager.box(
      HiveBoxes.recentSearches,
    ).delete(HiveKeys.lastSearchResults),
  );

  test('keeps the five newest unique cards of each type', () async {
    const cache = LastSearchResultsCache();
    await cache.save(
      [for (var id = 1; id <= 5; id++) sampleProduct(id: id)],
      [for (var id = 1; id <= 5; id++) sampleStore(id: id)],
    );
    await cache.save(
      [sampleProduct(id: 6), sampleProduct(id: 3, en: 'Updated product')],
      [sampleStore(id: 6), sampleStore(id: 4, en: 'Updated store')],
    );
    await cache.save([sampleProduct(id: 7)], []);
    await cache.save([], []);

    final results = await cache.watch().first;
    expect(results.products.map((card) => card.routeId), [
      'p7',
      'p6',
      'p3',
      'p1',
      'p2',
    ]);
    expect(results.stores.map((card) => card.routeId), [
      '6',
      '4',
      '1',
      '2',
      '3',
    ]);
    expect(results.products[2].en, 'Updated product');
    expect(results.stores[1].en, 'Updated store');
  });

  testWidgets('shows one list of product and store rows with the old shimmer', (
    tester,
  ) async {
    final List<String> productTerms = [];
    final List<String?> storeTerms = [];
    await pumpCategoriesScreen(
      tester,
      const Search2Screen(),
      overrides: [
        getFeaturedStoresProvider.overrideWith((ref) => _FeaturedStores()),
        getProductsProvider.overrideWith((ref, term) {
          productTerms.add(term);
          return _Products(term);
        }),
        getAllStoresProvider.overrideWith((ref, args) {
          storeTerms.add(args.searchKey);
          return _Stores(args);
        }),
      ],
      destinationRoutes: [
        GoRoute(
          name: AppRoutes.productDetailsScreen,
          path: '/product-details',
          builder: (context, state) =>
              Scaffold(body: Text('Product details ${state.extra}')),
        ),
        GoRoute(
          name: AppRoutes.storeDetailsScreen,
          path: '/store-details/:id',
          builder: (context, state) => Scaffold(
            body: Text('Store details ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    expect(find.byType(SearchPlaceholderView), findsOneWidget);
    expect(find.text('Featured brand'), findsOneWidget);
    expect(find.text(LangKeys.lastThingYouSearchedForKey), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SearchResultsView), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(productTerms, isEmpty);
    expect(storeTerms, isEmpty);

    await tester.enterText(find.byType(TextField), 'tv');
    await tester.pump(const Duration(seconds: 1));
    expect(productTerms, isEmpty);
    expect(storeTerms, isEmpty);
    expect(find.byType(SearchResultsView), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Laptop');
    await tester.pump();
    expect(productTerms, isEmpty);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SearchResultsView), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(productTerms, ['Laptop']);
    expect(storeTerms, ['Laptop']);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(AppCachedNetworkImage), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('Product')).dy,
      lessThan(tester.getTopLeft(find.text('Store')).dy),
    );
    expect(find.text(LangKeys.productsKey), findsNothing);
    expect(find.text(LangKeys.storesKey), findsNothing);
    expect(find.byType(NoResultsWidget), findsNothing);

    await tester.enterText(find.byType(TextField), 'loading');
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AppShimmer), findsWidgets);
    expect(find.byType(NoResultsWidget), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.byType(SearchResultsView), findsOneWidget);
    await tester.tap(find.byType(Search2BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SearchPlaceholderView), findsOneWidget);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(find.text(LangKeys.lastThingYouSearchedForKey), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Product')).dx,
      lessThan(tester.getTopLeft(find.text('Store')).dx),
    );
    final router = GoRouter.of(
      tester.element(find.byType(SearchPlaceholderView)),
    );
    await tester.tap(find.text('Product'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Product details p1'), findsOneWidget);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Store'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Store details 1'), findsOneWidget);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text(LangKeys.editKey));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();
    expect(find.text('Product'), findsNothing);
    expect(find.text('Store'), findsOneWidget);
    final Finder placeholderField = find.descendant(
      of: find.byType(SearchPlaceholderView),
      matching: find.byType(TextField),
    );
    await tester.enterText(placeholderField, '  missing  ');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
    expect(tester.testTextInput.isVisible, isTrue);
    expect(productTerms, ['Laptop', 'loading', 'missing']);
    expect(storeTerms, ['Laptop', 'loading', 'missing']);
    expect(find.byType(NoResultsWidget), findsOneWidget);
    expect(find.text(LangKeys.noSearchMatchesKey), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SearchPlaceholderView), findsOneWidget);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(find.text(LangKeys.lastThingYouSearchedForKey), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      isEmpty,
    );
  });

  testWidgets('shows a shimmer while reading and hides on a cache error', (
    tester,
  ) async {
    final cache = StreamController<LastSearchResults>();
    await pumpCategoriesScreen(
      tester,
      const Search2Screen(),
      overrides: [
        getFeaturedStoresProvider.overrideWith((ref) => _FeaturedStores()),
        lastSearchResultsProvider.overrideWith((ref) => cache.stream),
      ],
    );

    final section = find.byType(Search2RecentSearchSection);
    expect(
      tester.widget<Search2RecentSearchSection>(section).isLoading,
      isTrue,
    );
    expect(
      find.descendant(of: section, matching: find.byType(AppShimmer)),
      findsOneWidget,
    );
    cache.addError(const FormatException('Invalid search cache'));
    await cache.close();
    await tester.pump();
    expect(section, findsNothing);
  });
}

class _Products extends GetProductsViewModel {
  _Products(String term) : super(search: term) {
    if (term == 'loading') return;
    state = AsyncValue.data(
      pageOf<ProductModel>([if (term == 'Laptop') sampleProduct()]),
    );
  }
}

class _Stores extends GetAllStoresViewModel {
  _Stores(AllStoresArgs args) : super(args: args) {
    if (args.searchKey == 'loading') return;
    state = AsyncValue.data(
      pageOf<StoreModel>([if (args.searchKey == 'Laptop') sampleStore()]),
    );
  }
}

class _FeaturedStores extends GetFeaturedStoresViewModel {
  _FeaturedStores() {
    state = AsyncValue.data(
      pageOf<StoreModel>([
        const StoreModel(id: 1, name: {'en': 'Featured brand'}),
      ]),
    );
  }
}
