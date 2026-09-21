/// API endpoints owned by the stores feature.
///
/// Paths and query maps are built from the caller's arguments — the class holds
/// no request state of its own, so concurrent requests (e.g. two filter tabs on
/// the store details screen paging at the same time) can't clobber each other.
abstract class StoresEndpoints {
  static const int _perPage = 15;

  static const String getStores = '/api/v1/stores';
  static const String getFeaturedStores = '$getStores/featured';

  static String storeDetails(int storeId) => '$getStores/$storeId';

  static String storeProducts(int storeId) => '$getStores/$storeId/products';

  static Map<String, dynamic> storesQuery({
    required int page,
    String? search,
    int? categoryId,
    String? rating,
  }) => <String, dynamic>{
    'per_page': _perPage,
    'page': page,
    'category_id': ?categoryId,
    if (rating != null && rating.isNotEmpty) 'rating': rating,
    if (search != null && search.isNotEmpty) 'search': search,
  };

  /// Query parameters for [storeProducts].
  ///
  /// [categoryId] narrows the store's products to one of its categories — the
  /// store-details category chips. It is omitted entirely when null, which is
  /// what the filter tabs (all / offers / top rated / …) send.
  static Map<String, dynamic> storeProductsQuery({
    required int page,
    required String filter,
    int? categoryId,
    String? search,
  }) => <String, dynamic>{
    'per_page': _perPage,
    'page': page,
    'filter': filter,
    'category_id': ?categoryId,
    if (search != null && search.isNotEmpty) 'search': search,
  };
}
