import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_category_model.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/favourite_categories_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/get_favourite_products_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/get_favourite_stores_vm.dart';

// Reuse the categories harness for localization, pumping helpers and the
// shared product/store/page fixtures — the favourites widgets live in the same
// ambient (EasyLocalization + ProviderScope + themed MaterialApp).
export 'categories_test_harness.dart';
// So tests referencing the chip model only need to import this harness.
export 'package:nowdelivery_user_app/features/favourites/data/models/favourite_category_model.dart';

/// Records the `(search, categoryIds, sort)` a tab view pushes into its
/// view-model, so a test can assert what a search / chip / sort produced.
typedef ApplyFiltersSpy = void Function(
  String? search,
  List<int> categoryIds,
  String? sort,
);

// ---------------------------------------------------------------------------
// Provider overrides (faked view-models — no repo, no network)
// ---------------------------------------------------------------------------

Override overrideFavouriteProducts(
  AsyncValue<PaginationModel<ProductModel>> state, {
  ApplyFiltersSpy? onApplyFilters,
}) =>
    getFavouriteProductsProvider.overrideWith(
      (Ref ref) => _FakeFavouriteProductsVM(state, onApplyFilters),
    );

Override overrideFavouriteStores(
  AsyncValue<PaginationModel<StoreModel>> state, {
  ApplyFiltersSpy? onApplyFilters,
}) =>
    getFavouriteStoresProvider.overrideWith(
      (Ref ref) => _FakeFavouriteStoresVM(state, onApplyFilters),
    );

/// Overrides the chip row for every tab (the family is keyed by type).
Override overrideFavouriteCategories(
  AsyncValue<List<FavouriteCategoryModel>> state,
) =>
    favouriteCategoriesProvider.overrideWith(
      (Ref ref, String type) => _FakeFavouriteCategoriesVM(type, state),
    );

class _FakeFavouriteProductsVM extends GetFavouriteProductsViewModel {
  _FakeFavouriteProductsVM(
    AsyncValue<PaginationModel<ProductModel>> initial,
    this._onApplyFilters,
  ) {
    state = initial;
  }

  final ApplyFiltersSpy? _onApplyFilters;

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<void> loadNextPage() async {}

  @override
  Future<void> applyFilters({
    String? search,
    List<int>? categoryIds,
    String? sort,
  }) async {
    _onApplyFilters?.call(search, categoryIds ?? const <int>[], sort);
  }

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}

class _FakeFavouriteStoresVM extends GetFavouriteStoresViewModel {
  _FakeFavouriteStoresVM(
    AsyncValue<PaginationModel<StoreModel>> initial,
    this._onApplyFilters,
  ) {
    state = initial;
  }

  final ApplyFiltersSpy? _onApplyFilters;

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<void> loadNextPage() async {}

  @override
  Future<void> applyFilters({
    String? search,
    List<int>? categoryIds,
    String? sort,
  }) async {
    _onApplyFilters?.call(search, categoryIds ?? const <int>[], sort);
  }

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}

class _FakeFavouriteCategoriesVM extends FavouriteCategoriesViewModel {
  _FakeFavouriteCategoriesVM(
    super.type,
    AsyncValue<List<FavouriteCategoryModel>> initial,
  ) {
    state = initial;
  }

  @override
  Future<void> load() async {}
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

FavouriteCategoryModel sampleFavouriteCategory({
  int id = 1,
  String en = 'Food',
  int count = 3,
}) =>
    FavouriteCategoryModel(
      id: id,
      name: <String, dynamic>{'en': en, 'ar': en},
      favoritablesCount: count,
    );
