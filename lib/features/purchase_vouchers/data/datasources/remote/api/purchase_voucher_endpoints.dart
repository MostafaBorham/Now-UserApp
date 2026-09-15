
abstract class PurchaseVoucherEndpoints {

  static const String purchaseVouchers = '/api/v1/purchase-vouchers';

  static int perPage = 10;



  static Map<String, dynamic> listQuery({int? storeId, int page = 1}) =>
      <String, dynamic>{
        'per_page': perPage,
        'page': page,
        'store_id': ?storeId,
      };
}
