import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/products/data/repo/products_repo.dart';

final getProductsProvider =
    StateNotifierProvider.autoDispose<GetProductsViewModel,
        AsyncValue<List<ProductModel>>>(
  (Ref ref) => GetProductsViewModel(const AsyncValue.loading()),
);

class GetProductsViewModel
    extends StateNotifier<AsyncValue<List<ProductModel>>> {
  GetProductsViewModel(super.initialState);

  final ProductsRepo _repo = ProductsRepo();

  int _requestId = 0;

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getProducts({String? search}) async {
    _repo.cancelRequests();
    final int requestId = ++_requestId;

    state = const AsyncValue.loading();

    final result = await _repo.getProducts(search: search);

    if (!mounted || requestId != _requestId) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<ProductModel> products) => AsyncValue.data(products),
    );
  }

  void updateProductFavourite(int? productId, bool isFavourite) {
    final List<ProductModel>? products = state.valueOrNull;
    if (products == null) return;

    state = AsyncValue<List<ProductModel>>.data(<ProductModel>[
      for (final ProductModel product in products)
        product.id == productId
            ? product.copyWith(isFavorite: isFavourite)
            : product,
    ]);
  }
}
