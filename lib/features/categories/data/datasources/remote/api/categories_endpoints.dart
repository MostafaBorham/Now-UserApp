/// API endpoints owned by the categories feature.
abstract class CategoriesEndpoints {
  static const String getCategories = '/api/v1/categories/tree';

  /// Query parameters for [getCategories]: only root categories + one level.
  static const Map<String, dynamic> getCategoriesQuery = <String, dynamic>{
    'max_depth': 1,
  };
}
