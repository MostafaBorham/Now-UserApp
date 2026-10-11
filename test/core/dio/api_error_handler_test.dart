import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

void main() {
  test('a validation error shows its first field message (BUG-020)', () {
    expect(
      ApiErrorHandler.extractErrorMessage(<String, dynamic>{
        'message': 'فشل التحقق من البيانات',
        'errors': <String, dynamic>{
          'floor': <String>['يجب ألا يزيد الطابق عن 50 حرفًا.'],
          'building_number': <String>['حقل المبنى مطلوب.'],
        },
      }),
      'يجب ألا يزيد الطابق عن 50 حرفًا.',
    );
  });

  test('without field messages it falls back to message, then the key', () {
    expect(
      ApiErrorHandler.extractErrorMessage(<String, dynamic>{
        'message': 'Insufficient balance',
        'errors': <String, dynamic>{},
      }),
      'Insufficient balance',
    );
    expect(
      ApiErrorHandler.extractErrorMessage(<String, dynamic>{
        'errors': <String, dynamic>{'floor': <String>[]},
      }),
      LangKeys.somethingWentWrongKey,
    );
    expect(
      ApiErrorHandler.extractErrorMessage(null),
      LangKeys.somethingWentWrongKey,
    );
  });

  // QA-003 A2/A3: one wording rule for a failed request, in every repo.
  test('messageForDio words a failure by its cause', () {
    String forStatus(int? status, {dynamic data}) {
      final RequestOptions options = RequestOptions(path: '/x');
      return ApiErrorHandler.messageForDio(
        DioException(
          requestOptions: options,
          response: status == null
              ? null
              : Response<dynamic>(
                  requestOptions: options,
                  statusCode: status,
                  data: data,
                ),
        ),
      );
    }

    expect(forStatus(null), LangKeys.serverConnectionFailedKey);
    expect(
      forStatus(500, data: <String, dynamic>{'message': 'Server Error'}),
      LangKeys.serverUnavailableKey,
    );
    expect(forStatus(503, data: '<html>'), LangKeys.serverUnavailableKey);
    expect(forStatus(413), LangKeys.serverUnavailableKey);
    expect(
      forStatus(405, data: <String, dynamic>{'message': 'Method POST…'}),
      LangKeys.somethingWentWrongKey,
    );
    expect(
      forStatus(422, data: <String, dynamic>{'message': 'Coupon expired'}),
      'Coupon expired',
    );
  });
}
