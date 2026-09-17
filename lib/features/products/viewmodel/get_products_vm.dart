import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/products/data/repo/products_repo.dart';






final getProductsProvider =
    StateNotifierProvider.autoDispose<GetProductsViewModel,
        AsyncValue<List<ProductModel>>>(
  (Ref ref) =>
  GetProductsViewModel(const AsyncValue.loading()),
);

final getProductsByCategoryFilterProvider = StateNotifierProvider.autoDispose.family<
    GetProductsViewModel,
    AsyncValue<List<ProductModel>>,
    int?>(
      (ref, categoryId) {
    return GetProductsViewModel(
      const AsyncValue.loading(),
    );
  },
);
class GetProductsViewModel
    extends StateNotifier<AsyncValue<List<ProductModel>>> {
  GetProductsViewModel(super.initialState);

  final ProductsRepo _repo = ProductsRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getProducts({int? categoryId}) async {
    state = const AsyncValue.loading();

    final result = await _repo.getProducts(categoryId: categoryId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<ProductModel> products) => AsyncValue.data(products),
    );
  }
}
