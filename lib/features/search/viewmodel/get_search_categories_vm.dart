import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

final searchCategoriesProvider = StateNotifierProvider.autoDispose<
    SearchCategoriesViewModel, AsyncValue<PaginationModel<CategoryModel>>>(
  (Ref ref) => SearchCategoriesViewModel(ref),
);

class SearchCategoriesViewModel extends PaginatedViewModel<CategoryModel> {
  SearchCategoriesViewModel(this._ref) {
    _showUnfiltered();
  }

  final Ref _ref;
  final CategoriesRepo _repo = CategoriesRepo();

  String _searchKey = '';

  String get searchKey => _searchKey;

  void search(String term) {
    final String trimmed = term.trim();
    if (trimmed == _searchKey) return;
    if (trimmed.isEmpty) {
      _showUnfiltered();
    } else {
      _searchKey = trimmed;
      loadFirstPage();
    }
  }

  void _showUnfiltered() {
    _searchKey = '';
    final PaginationModel<CategoryModel>? preloaded =
        _ref.read(getAppCategoriesProvider).valueOrNull;
    if (preloaded != null) {
      state = AsyncValue<PaginationModel<CategoryModel>>.data(preloaded);
    } else {
      loadFirstPage();
    }
  }

  @override
  Future<Either<Failure, PaginationModel<CategoryModel>>> fetchPage(int page) {
    return _repo.getAppCategories(
      page: page,
      search: _searchKey.isEmpty ? null : _searchKey,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
