import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/products/data/repo/products_repo.dart';






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

  /// Loads the product, or reloads it for pull-to-refresh. A reload keeps the
  /// loaded product on screen: flipping back to a bare loading state swapped
  /// the page for its shimmer, which unmounted the stepper and the option
  /// pickers and so threw away the shopper's quantity, colour and size.
  Future<void> getProductDetails() async {
    state = state.hasValue
        ? const AsyncValue<ProductModel>.loading().copyWithPrevious(state)
        : const AsyncValue<ProductModel>.loading();

    final result = await _repo.getProductDetails(productSlug: productSlug);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (ProductModel product) => AsyncValue.data(product),
    );
  }
}
