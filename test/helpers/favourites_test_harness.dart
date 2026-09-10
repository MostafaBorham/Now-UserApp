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

// ---------------------------------------------------------------------------
// Provider overrides (faked view-models — no repo, no network)
// ---------------------------------------------------------------------------

/// Fakes every category-tab query of the favourites Products tab with the same
/// [state]. The provider is a `family` keyed by [FavouriteProductsArgs] (the
/// selected category + search key), so the override matches on `(ref, args)`
/// and hands back the same faked page whatever the current filter — a test
/// asserts on what the widget renders, not on which page it fetched.
Override overrideFavouriteProducts(
  AsyncValue<PaginationModel<ProductModel>> state,
) =>
    getFavouriteProductsProvider.overrideWith(
      (Ref ref, FavouriteProductsArgs args) =>
          _FakeFavouriteProductsVM(state, args),
    );

/// Fakes every category-tab query of the favourites Stores tab with the same
/// [state]. Keyed by [FavouriteStoresArgs] exactly like
/// [overrideFavouriteProducts].
Override overrideFavouriteStores(
  AsyncValue<PaginationModel<StoreModel>> state,
) =>
    getFavouriteStoresProvider.overrideWith(
      (Ref ref, FavouriteStoresArgs args) =>
          _FakeFavouriteStoresVM(state, args),
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
    FavouriteProductsArgs args,
  ) : super(args: args) {
    state = initial;
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<void> loadNextPage() async {}

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) =>
      throw UnimplementedError('fake view-model must not fetch');
}

class _FakeFavouriteStoresVM extends GetFavouriteStoresViewModel {
  _FakeFavouriteStoresVM(
    AsyncValue<PaginationModel<StoreModel>> initial,
    FavouriteStoresArgs args,
  ) : super(args: args) {
    state = initial;
  }

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<void> loadNextPage() async {}

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
