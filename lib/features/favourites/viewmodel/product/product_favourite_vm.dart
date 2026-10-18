import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// Family provider keyed by product ID plus its initial favourite state.
///
/// Handles both adding and removing a product from favourites. The state holds
/// `true` when the product is favourited and `false` otherwise, seeded with the
/// [({int productId, bool isFavourite})] passed on creation.
///
/// Usage:
/// ```dart
/// final args = (productId: productId, isFavourite: product.isFavourite);
/// final state = ref.watch(productFavouriteProvider(args));
/// ref.read(productFavouriteProvider(args).notifier).addToFavourites();
/// ref.read(productFavouriteProvider(args).notifier).removeFromFavourites();
/// ```
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
  /// [repo] is injectable for tests.
  ProductFavouriteViewModel(
    super.initialState,
    this._productId, {
    FavouritesRepo? repo,
  }) : _repo = repo ?? FavouritesRepo();

  final int _productId;
  final FavouritesRepo _repo;

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

  /// Loading that already carries [isFavourite], so the heart flips on tap.
  /// `isRefresh: false` keeps it a loading to listeners, so nothing treats it
  /// as confirmed; a failure carries no value, so the icon falls back to the
  /// last confirmed status.
  static AsyncValue<bool> _optimistic(bool isFavourite) =>
      const AsyncLoading<bool>().copyWithPrevious(
        AsyncData<bool>(isFavourite),
        isRefresh: false,
      );

  Future<void> addToFavourites() async {
    state = _optimistic(true);

    final result = await _repo.addProductToFavourites(productId: _productId);

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

    final result =
        await _repo.removeProductFromFavourites(productId: _productId);

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
