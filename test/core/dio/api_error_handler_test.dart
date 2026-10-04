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
}
