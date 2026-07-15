import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: fetch the categories list for the categories screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCategoriesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCategoriesProvider.notifier).getCategories()`.
final getStoreSubCategoriesProvider =
    StateNotifierProvider.autoDispose<GetStoreSubCategoriesViewModel,
        AsyncValue<List<CategoryModel>>>(
  (Ref ref) =>
      GetStoreSubCategoriesViewModel(const AsyncValue.loading())..getStoreSubCategories(),
);

class GetStoreSubCategoriesViewModel
    extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  GetStoreSubCategoriesViewModel(super.initialState);

  final CategoriesRepo _repo = CategoriesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getStoreSubCategories() async {
    state = const AsyncValue.loading();

    final result = await _repo.getStoreSubCategories();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<CategoryModel> categories) => AsyncValue.data(categories),
    );
  }
}
