/// API endpoints owned by the promotion feature.
abstract class PromotionEndpoints {
  static const String coupons = '/api/v1/coupons';

  /// A single coupon looked up by its code, e.g. `/api/v1/coupons/WELCOME10`.
  static String couponByCode(String code) => '$coupons/$code';

  static int perPage = 15;
  static int page = 1;

  /// Query parameters for getCoupons
  static Map<String, dynamic> get getCouponsQuery => {
    'per_page': perPage,
    'page': page,
  };
}
