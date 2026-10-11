import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/local/welcome_voucher_cache_service.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/remote/api/promotion_api_service.dart';
import 'package:nowdelivery_user_app/features/promotion/data/repo/promotion_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every coupon lookup with [status].
class _FakeApi extends PromotionApiService {
  _FakeApi(this.status);

  final int status;

  @override
  Future<Response<dynamic>> getCoupon(String code) async {
    final RequestOptions options = RequestOptions(path: '/coupons/$code');
    final Response<dynamic> response = Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: status == 200
          ? <String, dynamic>{
              'success': true,
              'data': <String, dynamic>{
                'coupon': <String, dynamic>{'code': code},
              },
            }
          : <String, dynamic>{'success': false, 'message': 'Not found'},
    );
    if (status >= 400) {
      throw DioException.badResponse(
        statusCode: status,
        requestOptions: options,
        response: response,
      );
    }
    return response;
  }
}

// BUG-022: a welcome code the admin switched off lived on from the cache,
// because any failure fell back to it.
void main() {
  final WelcomeVoucherCacheService cache = WelcomeVoucherCacheService();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefManager.init();
    await cache.saveWelcomeCode('OLD10');
  });

  Future<Either<Failure, CouponModel>> fetch({
    required bool online,
    int status = 200,
  }) => PromotionRepo(
    api: _FakeApi(status),
    isConnected: () async => online,
  ).getWelcomeVoucher('WELCOME10');

  test('offline, the cached code stands in', () async {
    final Either<Failure, CouponModel> result = await fetch(online: false);
    expect(result.getOrElse(() => const CouponModel()).code, 'OLD10');
  });

  test("online, the server's 404 stands and the cache is cleared", () async {
    final Either<Failure, CouponModel> result = await fetch(
      online: true,
      status: 404,
    );
    expect(result.isLeft(), isTrue);
    expect(cache.getWelcomeCode(), isNull);
  });

  test('online, a live code replaces the cached one', () async {
    final Either<Failure, CouponModel> result = await fetch(online: true);
    expect(result.getOrElse(() => const CouponModel()).code, 'WELCOME10');
    expect(cache.getWelcomeCode(), 'WELCOME10');
  });
}
