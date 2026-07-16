import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

/// Single task: fetch the products of one store category for the
/// view-store-category-products screen.
///
/// The screen kicks off the fetch itself (it owns the category slug/id), so
/// widgets `ref.watch(getStoreCategoryProductsProvider)` to render the
/// [AsyncValue] and call
/// `ref.read(getStoreCategoryProductsProvider.notifier).getStoreCategoryProducts(...)`
/// to (re)load.
final getStoreCategoryProductsProvider = StateNotifierProvider.autoDispose<
    GetStoreCategoryProductsViewModel,
    AsyncValue<List<ProductModel>>>(
  (Ref ref) => GetStoreCategoryProductsViewModel(const AsyncValue.loading()),
);

class GetStoreCategoryProductsViewModel
    extends StateNotifier<AsyncValue<List<ProductModel>>> {
  GetStoreCategoryProductsViewModel(super.initialState);

  final StoresRepo _repo = StoresRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getStoreCategoryProducts({
    required int storeId,
    required int? categoryId,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repo.getStoreCategoryProducts(
      storeId: storeId,
      categoryId: categoryId,
    );

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<ProductModel> products) => AsyncValue.data(products),
    );
  }
}
