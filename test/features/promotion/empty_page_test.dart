import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/remote/api/promotion_api_service.dart';
import 'package:nowdelivery_user_app/features/promotion/data/repo/promotion_repo.dart';

/// Answers the coupons list with [data] as the envelope's `data`.
class _FakeApi extends PromotionApiService {
  _FakeApi(this.data);

  final dynamic data;

  @override
  Future<Response<dynamic>> getCoupons({required int page}) async =>
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/coupons'),
        statusCode: 200,
        data: <String, dynamic>{'success': true, 'data': data},
      );
}

// BUG-003: an empty page sent as `"data": []` threw in the `Map` cast, and the
// screen said "server connection failed" instead of "nothing here".
void main() {
  test('responseData reads a list or a missing data as empty', () {
    expect(responseData(<String, dynamic>{'data': <dynamic>[]}), isEmpty);
    expect(responseData(<String, dynamic>{}), isEmpty);
    expect(
      responseData(<String, dynamic>{
        'data': <String, dynamic>{'a': 1},
      }),
      <String, dynamic>{'a': 1},
    );
  });

  test('an empty list page is an empty page, not an error', () async {
    final Either<Failure, PaginationModel<CouponModel>> result =
        await PromotionRepo(
          api: _FakeApi(<dynamic>[]),
          isConnected: () async => true,
        ).getCoupons(page: 1);

    expect(result.isRight(), isTrue);
    result.fold((_) {}, (PaginationModel<CouponModel> page) {
      expect(page.data, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });
}
