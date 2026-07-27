import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// Family provider keyed by product ID — each product gets its own state.
///
/// Usage:
/// ```dart
/// final state = ref.watch(addProductToFavouritesProvider(productId));
/// ref.read(addProductToFavouritesProvider(productId).notifier).addProductToFavourites();
/// ```
final addProductToFavouritesProvider = StateNotifierProvider.autoDispose
    .family<AddProductToFavouritesViewModel, AsyncValue<FavouriteModel?>, int>(
  (Ref ref, int productId) =>
      AddProductToFavouritesViewModel(const AsyncValue.data(null), productId),
);

class AddProductToFavouritesViewModel
    extends StateNotifier<AsyncValue<FavouriteModel?>> {
  AddProductToFavouritesViewModel(super.initialState, this._productId);

  final int _productId;
  final FavouritesRepo _repo = FavouritesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> addProductToFavourites() async {
    state = const AsyncValue.loading();

    final result =
        await _repo.addProductToFavourites(productId: _productId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (FavouriteModel favourite) => AsyncValue.data(favourite),
    );
  }
}
