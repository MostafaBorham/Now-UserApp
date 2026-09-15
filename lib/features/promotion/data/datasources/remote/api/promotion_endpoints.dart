
abstract class PromotionEndpoints {
  static const String coupons = '/api/v1/coupons';


  static String couponByCode(String code) => '$coupons/$code';

  static int perPage = 15;
  static int page = 1;


  static Map<String, dynamic> get getCouponsQuery => {
    'per_page': perPage,
    'page': page,
  };
}
