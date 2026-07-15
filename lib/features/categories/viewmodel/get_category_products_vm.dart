import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: fetch the categories list for the categories screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCategoriesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCategoriesProvider.notifier).getCategories()`.
final getCategoryProductsProvider =
    StateNotifierProvider.autoDispose<GetCategoryProductsViewModel,
        AsyncValue<List<ProductModel>>>(
  (Ref ref) =>
      GetCategoryProductsViewModel(const AsyncValue.loading()),
);

/*final filterCategoryProductsProvider =
StateNotifierProvider.autoDispose.family<
    GetCategoryProductsViewModel,
    AsyncValue<List<ProductModel>>,
    int?>(
      (ref, categoryId) {
    return GetCategoryProductsViewModel(
      const AsyncValue.loading(),
    );
  },
);*/

class GetCategoryProductsViewModel
    extends StateNotifier<AsyncValue<List<ProductModel>>> {
  GetCategoryProductsViewModel(super.initialState);

  final CategoriesRepo _repo = CategoriesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getCategoryProducts({required String categorySlug,required int? categoryId}) async {
    state = const AsyncValue.loading();

    final result = await _repo.getCategoryProducts(categorySlug: categorySlug,categoryId: categoryId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (products) => AsyncValue.data(products),
    );
  }
}
