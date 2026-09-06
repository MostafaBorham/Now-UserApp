/// API endpoints owned by the purchase-vouchers feature.
abstract class PurchaseVoucherEndpoints {
  /// Public, paginated list of currently-valid purchase vouchers.
  static const String purchaseVouchers = '/api/v1/purchase-vouchers';

  static int perPage = 10;

  /// Query for the list. [storeId] returns platform-wide vouchers plus that
  /// store's vouchers; `null` returns everything.
  static Map<String, dynamic> listQuery({int? storeId, int page = 1}) =>
      <String, dynamic>{
        'per_page': perPage,
        'page': page,
        'store_id': ?storeId,
      };
}
