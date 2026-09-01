import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

/// Single task: fetch the details of one store for the store details screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getStoreDetailsProvider(storeId))` and render the
/// [AsyncValue].
/// Retry with `ref.read(getStoreDetailsProvider(storeId).notifier).getStoreDetails()`.
final getStoreDetailsProvider = StateNotifierProvider.autoDispose.family<
    GetStoreDetailsViewModel,
    AsyncValue<StoreModel>,
    int>(
      (ref, storeId) {
    return GetStoreDetailsViewModel(const AsyncValue.loading(), storeId: storeId)
      ..getStoreDetails();
  },
);

class GetStoreDetailsViewModel
    extends StateNotifier<AsyncValue<StoreModel>> {
  GetStoreDetailsViewModel(super.initialState, {required this.storeId});

  final int storeId;
  final StoresRepo _repo = StoresRepo();

  Future<void> getStoreDetails() async {
    state = const AsyncValue.loading();

    final result = await _repo.getStoreDetails(storeId: storeId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (StoreModel store) => AsyncValue.data(store),
    );
  }

  /// Reloads the store in the background for pull-to-refresh.
  ///
  /// Unlike [getStoreDetails] it does *not* flip the state to loading, so the
  /// store currently on screen (and the refresh indicator running over it) stays
  /// put while the request is in flight — the header, banners and categories
  /// just update in place when it returns. A failed refresh keeps the existing
  /// store rather than replacing the whole screen with an error.
  Future<void> refresh() async {
    final result = await _repo.getStoreDetails(storeId: storeId);

    if (!mounted) return;

    result.fold(
      (Failure _) {},
      (StoreModel store) => state = AsyncValue<StoreModel>.data(store),
    );
  }

  void updateProductFavourite(int? productId, bool isFavourite) {
    final StoreModel? store = state.valueOrNull;
    final List<ProductModel>? products = store?.products;
    if (store == null || products == null || productId == null) return;

    final List<ProductModel> updated = <ProductModel>[
      for (final ProductModel product in products)
        product.id == productId
            ? product.copyWith(isFavorite: isFavourite)
            : product,
    ];

    state = AsyncValue<StoreModel>.data(store.copyWith(products: updated));
  }
}