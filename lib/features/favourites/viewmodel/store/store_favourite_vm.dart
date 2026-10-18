import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// Family provider keyed by store ID plus its initial favourite state.
///
/// Handles both adding and removing a store from favourites. The state holds
/// `true` when the store is favourited and `false` otherwise, seeded with the
/// [({int storeId, bool isFavourite})] passed on creation.
///
/// Usage:
/// ```dart
/// final args = (storeId: storeId, isFavourite: store.isFavourite);
/// final state = ref.watch(storeFavouriteProvider(args));
/// ref.read(storeFavouriteProvider(args).notifier).addToFavourites();
/// ref.read(storeFavouriteProvider(args).notifier).removeFromFavourites();
/// ```
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

  /// See `ProductFavouriteViewModel._optimistic`.
  static AsyncValue<bool> _optimistic(bool isFavourite) =>
      const AsyncLoading<bool>().copyWithPrevious(
        AsyncData<bool>(isFavourite),
        isRefresh: false,
      );

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  bool _errorPending = false;

  /// Claims the right to report the failure that just landed: true for the
  /// first caller, false for everyone after. One item can be on screen in
  /// several cards at once, all listening to this notifier; without this each
  /// of them toasted the same failure.
  bool claimError() {
    if (!_errorPending) return false;

    _errorPending = false;
    return true;
  }

  Future<void> addToFavourites() async {
    state = _optimistic(true);

    final result = await _repo.addStoreToFavourites(storeId: _storeId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) {
        _errorPending = true;
        return AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) => const AsyncValue.data(true),
    );
  }

  Future<void> removeFromFavourites() async {
    state = _optimistic(false);

    final result = await _repo.removeStoreFromFavourites(storeId: _storeId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) {
        _errorPending = true;
        return AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) => const AsyncValue.data(false),
    );
  }
}
