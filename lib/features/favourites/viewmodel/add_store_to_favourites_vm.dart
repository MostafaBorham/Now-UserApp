import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// Family provider keyed by store ID — each store gets its own state.
///
/// Usage:
/// ```dart
/// final state = ref.watch(addStoreToFavouritesProvider(storeId));
/// ref.read(addStoreToFavouritesProvider(storeId).notifier).addStoreToFavourites();
/// ```
final addStoreToFavouritesProvider = StateNotifierProvider.autoDispose
    .family<AddStoreToFavouritesViewModel, AsyncValue<FavouriteModel?>, int>(
  (Ref ref, int storeId) =>
      AddStoreToFavouritesViewModel(const AsyncValue.data(null), storeId),
);

class AddStoreToFavouritesViewModel
    extends StateNotifier<AsyncValue<FavouriteModel?>> {
  AddStoreToFavouritesViewModel(super.initialState, this._storeId);

  final int _storeId;
  final FavouritesRepo _repo = FavouritesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> addStoreToFavourites() async {
    state = const AsyncValue.loading();

    final result = await _repo.addStoreToFavourites(storeId: _storeId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (FavouriteModel favourite) => AsyncValue.data(favourite),
    );
  }
}
