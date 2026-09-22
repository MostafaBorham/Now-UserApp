import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';

Response<dynamic> _response(dynamic data, int statusCode) {
  return Response<dynamic>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: '/test'),
  );
}

Map<String, dynamic>? _bodyOf(Either<Failure, Map<String, dynamic>> result) =>
    result.fold((Failure _) => null, (Map<String, dynamic> body) => body);

String? _messageOf(Either<Failure, Map<String, dynamic>> result) =>
    result.fold((Failure failure) => failure.message, (_) => null);

void main() {
  group('readApiResponse — status handling', () {
    test('accepts the whole 2xx range, not just 200', () {
      // The bug this replaces: `statusCode != 200` reported a successful
      // 201/202/204 as a failure — how every wallet top-up came back "failed".
      for (final int code in <int>[200, 201, 202, 204]) {
        final result = readApiResponse(
          _response(<String, dynamic>{'success': true}, code),
        );
        expect(_bodyOf(result), isNotNull, reason: 'status $code must succeed');
      }
    });

    test('a status outside 2xx is a failure carrying the server message', () {
      final result = readApiResponse(
        _response(<String, dynamic>{'message': 'Too many requests'}, 429),
      );

      expect(_bodyOf(result), isNull);
      expect(_messageOf(result), 'Too many requests');
    });
  });

  group('readApiResponse — body shape', () {
    test('a 2xx with a null body yields an empty map, not a crash', () {
      // `response.data as Map<String, dynamic>` used to throw a raw _TypeError
      // here, which reached the user as an untranslated Dart error string.
      expect(_bodyOf(readApiResponse(_response(null, 204))), isEmpty);
    });

    test('a 2xx with a list or string body yields an empty map', () {
      expect(_bodyOf(readApiResponse(_response(<dynamic>[], 200))), isEmpty);
      expect(_bodyOf(readApiResponse(_response('<html>', 200))), isEmpty);
    });

    test('a map body is returned unchanged', () {
      final body = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'id': 7},
      };

      expect(_bodyOf(readApiResponse(_response(body, 200))), same(body));
    });
  });

  group('readApiResponse — the success flag', () {
    test('is ignored unless requireSuccessFlag is set', () {
      final result = readApiResponse(
        _response(<String, dynamic>{'success': false}, 200),
      );

      expect(_bodyOf(result), isNotNull);
    });

    test('an explicit success:false is a failure when required', () {
      final result = readApiResponse(
        _response(
          <String, dynamic>{'success': false, 'message': 'Coupon expired'},
          200,
        ),
        requireSuccessFlag: true,
      );

      expect(_bodyOf(result), isNull);
      expect(_messageOf(result), 'Coupon expired');
    });

    test('an absent flag on a 204 is still a success', () {
      // A 204 carries no body and so no flag. Demanding one reported a
      // successful delete as a failure — the favourites unfavourite toast bug.
      final result = readApiResponse(
        _response(null, 204),
        requireSuccessFlag: true,
      );

      expect(_bodyOf(result), isEmpty);
    });
  });
}
