import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/get_favourite_products_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/get_favourite_stores_vm.dart';





export 'categories_test_harness.dart';








typedef FavouriteQuerySpy = void Function(int? categoryId, String? searchKey);





Override overrideFavouriteProducts(
  AsyncValue<PaginationModel<ProductModel>> state, {
  FavouriteQuerySpy? onQuery,
}) =>


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
