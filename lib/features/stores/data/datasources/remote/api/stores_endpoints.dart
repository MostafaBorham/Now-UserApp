/// API endpoints owned by the stores feature.
abstract class StoresEndpoints {
  static String get getStoreDetails =>
      '$getStores/$storeId';
  static const String getStores = '/api/v1/stores';
  static int? storeId;
}
