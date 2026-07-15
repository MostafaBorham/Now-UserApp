import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: fetch the categories list for the categories screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCategoriesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCategoriesProvider.notifier).getCategories()`.
final getAppCategoriesProvider =
    StateNotifierProvider.autoDispose<GetAppCategoriesViewModel,
        AsyncValue<List<CategoryModel>>>(
  (Ref ref) =>
      GetAppCategoriesViewModel(const AsyncValue.loading())..getAppCategories(),
);

class GetAppCategoriesViewModel
    extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  GetAppCategoriesViewModel(super.initialState){
    print('get app categories created');
  }

  final CategoriesRepo _repo = CategoriesRepo();



  @override
  void dispose() {
    _repo.cancelRequests();
    print('get app categories disposed');
    super.dispose();
  }

  Future<void> getAppCategories() async {
    print('get app categories call');
    state = const AsyncValue.loading();

    final result = await _repo.getAppCategories();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<CategoryModel> categories) => AsyncValue.data(categories),
    );
  }
}