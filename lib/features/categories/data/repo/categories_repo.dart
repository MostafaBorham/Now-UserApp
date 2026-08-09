import 'package:dartz/dartz.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/repo/base_repo.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_api_service.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

/// All data operations of the categories feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a clean server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
/// The connection check and error mapping live in [BaseRepo.guard].
class CategoriesRepo with BaseRepo {
  final CategoriesApiService _categoriesApiService = CategoriesApiService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _categoriesApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<CategoryModel>>> getAppCategories({
    required int page,
  }) {
    return guard(
      () => _categoriesApiService.getAppCategories(page: page),
      (data) => _paginated(data, 'categories', CategoryModel.fromJson),
    );
  }

  Future<Either<Failure, PaginationModel<StoreModel>>> getCategoryStores({
    required String categorySlug,
    required int? categoryId,
    required int page,
  }) {
    return guard(
      () => _categoriesApiService.getCategoryStores(
        categorySlug: categorySlug,
        categoryId: categoryId,
        page: page,
      ),
      (data) => _paginated(data, 'items', StoreModel.fromJson),
    );
  }

  Future<Either<Failure, PaginationModel<ProductModel>>> getCategoryProducts({
    required String categorySlug,
    required int? categoryId,
    required int page,
  }) {
    return guard(
      () => _categoriesApiService.getCategoryProducts(
        categorySlug: categorySlug,
        categoryId: categoryId,
        page: page,
      ),
      (data) => _paginated(data, 'items', ProductModel.fromJson),
    );
  }

  /// Turns a `{meta, <listKey>: [...]}` payload into a [PaginationModel]. The
  /// three list endpoints differ only by their list key and item type.
  PaginationModel<T> _paginated<T>(
    Map<String, dynamic> data,
    String listKey,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final Map<String, dynamic> meta = data['meta'] as Map<String, dynamic>;
    final List<dynamic> rawItems = data[listKey] as List<dynamic>? ?? <dynamic>[];
    final List<T> items = rawItems
        .map((dynamic e) => fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginationModel<T>.fromJson(meta, items);
  }
}
