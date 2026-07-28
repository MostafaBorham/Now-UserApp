import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: fetch the categories list for the categories screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCategoriesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCategoriesProvider.notifier).getCategories()`.
final getCategoryStoresProvider =
    StateNotifierProvider.autoDispose<GetCategoryStoresViewModel,
        AsyncValue<PaginationModel<StoreModel>>>(
  (Ref ref) =>
      GetCategoryStoresViewModel(const AsyncValue.loading()),
);

/*final filterCategoryStoresProvider =
StateNotifierProvider.autoDispose.family<
    GetCategoryStoresViewModel,
    AsyncValue<List<StoreModel>>,
    int?>(
      (ref, categoryId) {
    return GetCategoryStoresViewModel(
      const AsyncValue.loading(),
    );
  },
);*/

class GetCategoryStoresViewModel
    extends StateNotifier<AsyncValue<PaginationModel<StoreModel>>> {
  GetCategoryStoresViewModel(super.initialState);

  final CategoriesRepo _repo = CategoriesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getCategoryStores({required String categorySlug,required int? categoryId}) async {
    state = const AsyncValue.loading();

    final result = await _repo.getCategoryStores(categorySlug: categorySlug,categoryId: categoryId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (stores) => AsyncValue.data(stores),
    );
  }
}
