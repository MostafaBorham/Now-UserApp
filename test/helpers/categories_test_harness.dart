import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_all_stores_vm.dart';


















Future<void> initCategoriesTestLocalization() async {
  TestWidgetsFlutterBinding.ensureInitialized();


  SharedPreferences.setMockInitialValues(<String, Object>{});
  await EasyLocalization.ensureInitialized();
}






class _EmptyAssetLoader extends AssetLoader {
  const _EmptyAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{};
}









void _useDesignSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}



Future<void> pumpCategoriesWidget(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const <Override>[],
  bool useScaffold = true,
}) async {
  _useDesignSurface(tester);
  await tester.pumpWidget(
    _localizedApp(
      overrides: overrides,
      home: useScaffold ? Scaffold(body: child) : child,
    ),
  );
  await _settleLocalization(tester);
}





Future<void> pumpCategoriesScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const <Override>[],
}) async {
  _useDesignSurface(tester);
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => screen,
      ),
      GoRoute(
        name: AppRoutes.categoryDetailsScreen,
        path: '/category-details',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('__details__'))),
      ),
    ],
  );

  await tester.pumpWidget(_localizedApp(overrides: overrides, router: router));
  await _settleLocalization(tester);
}





Future<void> pumpSheetViaRouter(
  WidgetTester tester,
  Widget sheet, {
  List<Override> overrides = const <Override>[],
}) async {
  _useDesignSurface(tester);
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push('/sheet'),
              child: const Text('__home__'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/sheet',
        builder: (BuildContext context, GoRouterState state) =>
            Scaffold(body: sheet),
      ),
    ],
  );

  await tester.pumpWidget(_localizedApp(overrides: overrides, router: router));
  await _settleLocalization(tester);
  await tester.tap(find.text('__home__'));
  await _settleLocalization(tester);
}




Future<void> _settleLocalization(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Widget _localizedApp({
  required List<Override> overrides,
  Widget? home,
  GoRouter? router,
}) {
  return EasyLocalization(
    supportedLocales: LocalizationConstants.supportedLocales,
    path: LocalizationConstants.languagesPath,
    fallbackLocale: LocalizationConstants.englishLocale,
    startLocale: LocalizationConstants.englishLocale,
    assetLoader: const _EmptyAssetLoader(),
    child: ProviderScope(
      overrides: overrides,
      child: Builder(
        builder: (BuildContext context) {
          final ThemeData theme = AppThemes.getLightModeTheme();
          if (router != null) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              theme: theme,
              routerConfig: router,
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: theme,
            home: home,
          );
        },
      ),
    ),
  );
}





Override overrideAppCategories(
  AsyncValue<PaginationModel<CategoryModel>> state,
) =>
    getAppCategoriesProvider.overrideWith(
      (Ref ref) => _FakeAppCategoriesVM(state),
    );

Override overrideCategoryProducts(
  AsyncValue<PaginationModel<ProductModel>> state,
) =>


    getCategoryProductsProvider.overrideWith(
      (Ref ref, CategoryProductsArgs args) =>
          _FakeCategoryProductsVM(state, args),
    );

Override overrideCategoryStores(
  AsyncValue<PaginationModel<StoreModel>> state,
) =>


    getCategoryStoresProvider.overrideWith(
      (Ref ref, CategoryStoresArgs args) => _FakeCategoryStoresVM(state, args),
    );

Override overrideAllStores(
  AsyncValue<PaginationModel<StoreModel>> state,
) =>
    getAllStoresProvider.overrideWith(
      (Ref ref, AllStoresArgs args) => _FakeAllStoresVM(state, args),
    );

class _FakeAppCategoriesVM extends GetAppCategoriesViewModel {
  _FakeAppCategoriesVM(AsyncValue<PaginationModel<CategoryModel>> initial) {
    state = initial;
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<Either<Failure, PaginationModel<CategoryModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}

class _FakeCategoryProductsVM extends GetCategoryProductsViewModel {
  _FakeCategoryProductsVM(
    AsyncValue<PaginationModel<ProductModel>> initial,
    CategoryProductsArgs args,
  ) : super(args: args) {
    state = initial;
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}

class _FakeCategoryStoresVM extends GetCategoryStoresViewModel {
  _FakeCategoryStoresVM(
    AsyncValue<PaginationModel<StoreModel>> initial,
    CategoryStoresArgs args,
  ) : super(args: args) {
    state = initial;
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}

class _FakeAllStoresVM extends GetAllStoresViewModel {
  _FakeAllStoresVM(
    AsyncValue<PaginationModel<StoreModel>> initial,
    AllStoresArgs args,
  ) : super(args: args) {
    state = initial;
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}





CategoryModel sampleCategory({
  int id = 1,
  String slug = 'food',
  String en = 'Food',
  String ar = 'طعام',
}) =>
    CategoryModel(id: id, slug: slug, name: <String, dynamic>{'en': en, 'ar': ar});

List<CategoryModel> sampleCategories(int n) => List<CategoryModel>.generate(
      n,
      (int i) => sampleCategory(id: i + 1, slug: 'c$i', en: 'Category $i'),
    );

ProductModel sampleProduct({int id = 1, String en = 'Product'}) => ProductModel(
      id: id,
      slug: 'p$id',
      name: <String, dynamic>{'en': en, 'ar': en},
      price: 9.99,
    );

StoreModel sampleStore({int id = 1, String en = 'Store'}) => StoreModel(
      id: id,
      name: <String, dynamic>{'en': en, 'ar': en},
    );


PaginationModel<T> pageOf<T>(List<T> items, {bool hasMore = false}) =>
    PaginationModel<T>(
      currentPage: 1,
      lastPage: hasMore ? 2 : 1,
      perPage: 15,
      total: items.length,
      hasMore: hasMore,
      data: items,
    );
