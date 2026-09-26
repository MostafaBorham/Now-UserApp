import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_category_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// The category chip row for a favourites tab, keyed by API type
/// (`product` / `vendor`). Loaded once on first watch.
final favouriteCategoriesProvider = StateNotifierProvider.autoDispose.family<
    FavouriteCategoriesViewModel,
    AsyncValue<List<FavouriteCategoryModel>>,
    String>(
  (Ref ref, String type) => FavouriteCategoriesViewModel(type)..load(),
);

class FavouriteCategoriesViewModel
    extends StateNotifier<AsyncValue<List<FavouriteCategoryModel>>> {
  FavouriteCategoriesViewModel(this._type) : super(const AsyncValue.loading());

  final String _type;
  final FavouritesRepo _repo = FavouritesRepo();

  Future<void> load() async {
    state = const AsyncValue.loading();

    final result = await _repo.getFavouriteCategories(type: _type);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      AsyncValue.data,
    );
  }

  /// Reloads the chips without a loading flash — used after unfavouriting an
  /// item so a category with no remaining favourites drops out. Keeps the
  /// current chips on error rather than blanking the row.
  Future<void> refresh() async {
    final result = await _repo.getFavouriteCategories(type: _type);

    if (!mounted) return;

    result.fold(
      (Failure _) {},
      (List<FavouriteCategoryModel> categories) =>
          state = AsyncValue.data(categories),
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
