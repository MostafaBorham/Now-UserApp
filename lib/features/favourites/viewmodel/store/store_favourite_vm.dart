import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

final storeFavouriteProvider = StateNotifierProvider.autoDispose.family<
    StoreFavouriteViewModel,
    AsyncValue<bool>,
    ({int storeId, bool isFavourite})>(
  (Ref ref, ({int storeId, bool isFavourite}) args) => StoreFavouriteViewModel(
    AsyncValue.data(args.isFavourite),
    args.storeId,
  ),
);

class StoreFavouriteViewModel extends StateNotifier<AsyncValue<bool>> {
  StoreFavouriteViewModel(super.initialState, this._storeId);

  final int _storeId;
  final FavouritesRepo _repo = FavouritesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> addToFavourites() async {
    state = const AsyncValue.loading();

    final result = await _repo.addStoreToFavourites(storeId: _storeId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(true),
    );
  }

  Future<void> removeFromFavourites() async {
    state = const AsyncValue.loading();

    final result = await _repo.removeStoreFromFavourites(storeId: _storeId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(false),
    );
  }
}
