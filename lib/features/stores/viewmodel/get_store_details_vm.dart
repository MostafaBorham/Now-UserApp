import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

final getStoreDetailsProvider = StateNotifierProvider.autoDispose
    .family<GetStoreDetailsViewModel, AsyncValue<StoreModel>, int>((
      ref,
      storeId,
    ) {
      return GetStoreDetailsViewModel(
        const AsyncValue.loading(),
        storeId: storeId,
      )..getStoreDetails();
    });

class GetStoreDetailsViewModel extends StateNotifier<AsyncValue<StoreModel>> {
  GetStoreDetailsViewModel(super.initialState, {required this.storeId});

  final int storeId;
  final StoresRepo _repo = StoresRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

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

  /// Reloads the store without leaving the page: the loaded store stays on
  /// screen throughout and is kept on failure. Returns the failure message
  /// (null on success) so the pull that asked can say why nothing changed.
  Future<String?> refresh() async {
    final result = await _repo.getStoreDetails(storeId: storeId);

    if (!mounted) return null;

    return result.fold((Failure failure) => failure.message, (
      StoreModel store,
    ) {
      state = AsyncValue<StoreModel>.data(store);
      return null;
    });
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
