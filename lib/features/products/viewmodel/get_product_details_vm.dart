import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/products/data/repo/products_repo.dart';
import 'package:nowdelivery_user_app/features/products/data/repo/products_repo.dart';

/// Single task: fetch the categories list for the categories screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCategoriesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCategoriesProvider.notifier).getCategories()`.
final getProductDetailsProvider = StateNotifierProvider.autoDispose.family<
    GetProductDetailsViewModel,
    AsyncValue<ProductModel>,
    String>(
      (ref, productSlug) {
    return GetProductDetailsViewModel(AsyncValue.loading(),productSlug: productSlug)
      ..getProductDetails();
  },
);

class GetProductDetailsViewModel
    extends StateNotifier<AsyncValue<ProductModel>> {
  GetProductDetailsViewModel(super.initialState,{required this.productSlug});

  final String productSlug;
  final ProductsRepo _repo = ProductsRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getProductDetails() async {
    state = const AsyncValue.loading();

    final result = await _repo.getProductDetails(productSlug: productSlug);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (ProductModel product) => AsyncValue.data(product),
    );
  }
}
