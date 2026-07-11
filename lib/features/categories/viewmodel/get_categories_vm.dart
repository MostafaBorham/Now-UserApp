import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: fetch the categories list for the categories screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCategoriesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCategoriesProvider.notifier).getCategories()`.
final getCategoriesProvider =
    StateNotifierProvider.autoDispose<GetCategoriesViewModel,
        AsyncValue<List<CategoryModel>>>(
  (Ref ref) =>
      GetCategoriesViewModel(const AsyncValue.loading())..getCategories(),
);

class GetCategoriesViewModel
    extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  GetCategoriesViewModel(super.initialState);

  final CategoriesRepo _repo = CategoriesRepo();

  Future<void> getCategories() async {
    state = const AsyncValue.loading();

    final result = await _repo.getCategories();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<CategoryModel> categories) => AsyncValue.data(categories),
    );
  }
}
