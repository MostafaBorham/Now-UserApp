import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/get_favourite_products_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/get_favourite_stores_vm.dart';

// Reuse the categories harness for localization, pumping helpers and the
// shared product/store/page/category fixtures — the favourites widgets live in
// the same ambient (EasyLocalization + ProviderScope + themed MaterialApp), and
// their chip row is the app-category list, so `overrideAppCategories` fills it.
export 'categories_test_harness.dart';

/// Records the query one favourites list view asked for — the family key it
/// watched — so a test can assert what a search or a category tab produced.
///
/// Filters are no longer pushed into the view model; the search text and
/// selected category live in `favouritesFilterProvider` and reach the data
/// layer purely as the provider family key. So "the filter was applied" is
/// observed here, as the args a view requested.
typedef FavouriteQuerySpy = void Function(int? categoryId, String? searchKey);

// ---------------------------------------------------------------------------
// Provider overrides (faked view-models — no repo, no network)
// ---------------------------------------------------------------------------

Override overrideFavouriteProducts(
  AsyncValue<PaginationModel<ProductModel>> state, {
  FavouriteQuerySpy? onQuery,
}) =>
    // getFavouriteProductsProvider is a family: override every instance
    // (whatever its FavouriteProductsArgs) with a fake seeded to [state].
    getFavouriteProductsProvider.overrideWith(
      (Ref ref, FavouriteProductsArgs args) {
        onQuery?.call(args.categoryId, args.searchKey);
        return _FakeFavouriteProductsVM(state, args);
      },
    );

Override overrideFavouriteStores(
  AsyncValue<PaginationModel<StoreModel>> state, {
  FavouriteQuerySpy? onQuery,
}) =>
    // getFavouriteStoresProvider is a family: override every instance (whatever
    // its FavouriteStoresArgs) with a fake seeded to [state].
    getFavouriteStoresProvider.overrideWith(
      (Ref ref, FavouriteStoresArgs args) {
        onQuery?.call(args.categoryId, args.searchKey);
        return _FakeFavouriteStoresVM(state, args);
      },
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
