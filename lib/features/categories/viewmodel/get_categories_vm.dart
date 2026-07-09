import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';


final getCategoriesProvider =
StateNotifierProvider.autoDispose<
    GetCategoriesViewModel,
    AsyncValue<List<CategoryModel>?>>(
      (ref) => GetCategoriesViewModel(),
);

class GetCategoriesViewModel
    extends StateNotifier<AsyncValue<List<CategoryModel>?>> {
  GetCategoriesViewModel() : super(const AsyncValue.data(null));
  final CategoriesRepo repo = CategoriesRepo();
 Future getCategories() async {
    final result = await repo.getCategories();
    return result.fold(
      (Failure failure) {
        state = AsyncValue.error(failure.message, StackTrace.fromString(failure.message));
        },
      (List<CategoryModel> categories) {
        state = AsyncValue.data(categories);
      },
    );
  }
}