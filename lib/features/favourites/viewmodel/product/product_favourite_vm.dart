import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

final productFavouriteProvider = StateNotifierProvider.autoDispose.family<
    ProductFavouriteViewModel,
    AsyncValue<bool>,
    ({int productId, bool isFavourite})>(
  (Ref ref, ({int productId, bool isFavourite}) args) =>
      ProductFavouriteViewModel(
    AsyncValue.data(args.isFavourite),
    args.productId,
  ),
);

class ProductFavouriteViewModel extends StateNotifier<AsyncValue<bool>> {
  ProductFavouriteViewModel(super.initialState, this._productId);

  final int _productId;
  final FavouritesRepo _repo = FavouritesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> addToFavourites() async {
    state = const AsyncValue.loading();

    final result = await _repo.addProductToFavourites(productId: _productId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(true),
    );
  }

  Future<void> removeFromFavourites() async {
    state = const AsyncValue.loading();

    final result =
        await _repo.removeProductFromFavourites(productId: _productId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(false),
    );
  }
}
