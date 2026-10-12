import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/auth_token_interceptor.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/token_refresh_interceptor.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every request from a caller-supplied function — enough to decide
/// what the refresh endpoint replies with, which is the whole point here. The
/// request body is drained and handed over as text, as a server would read it.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.respond);

  final ResponseBody Function(RequestOptions options, String body) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final List<int> bytes = requestStream == null
        ? <int>[]
        : await requestStream.expand((Uint8List chunk) => chunk).toList();
    return respond(options, utf8.decode(bytes, allowMalformed: true));
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body, int statusCode) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );

void main() {
  const String protectedPath = '/api/v1/orders';

  late TokenCacheService tokens;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefManager.init();
    tokens = TokenCacheService();
    await tokens.saveUserTokens(
      accessToken: 'expired-access',
      refreshToken: 'the-refresh-token',
    );
    TokenRefreshInterceptor.onSessionExpired = null;
  });

  tearDown(() => TokenRefreshInterceptor.onSessionExpired = null);

  Dio buildWiredDio({
    required int refreshStatus,
    Map<String, dynamic>? refreshBody,
  }) {
    final Dio refreshDio = Dio()
      ..httpClientAdapter = _StubAdapter(
        (RequestOptions options, _) =>
            _json(refreshBody ?? <String, dynamic>{}, refreshStatus),
      );

    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _StubAdapter(
        (RequestOptions options, _) =>
            _json(<String, dynamic>{'message': 'Unauthenticated.'}, 401),
      );

    dio.interceptors
      ..add(AuthTokenInterceptor())
      ..add(TokenRefreshInterceptor(dio, refreshDio: refreshDio));

    return dio;
  }

  group('a refresh that never happened must not end the session', () {
    test('a 429 on refresh leaves the tokens in place', () async {
      // The refresh endpoint is rate limited per IP, so on a shared network one
      // customer can be throttled by another's traffic. That says nothing about
      // their refresh token, and used to sign them out anyway.
      final Dio dio = buildWiredDio(refreshStatus: 429);

      await expectLater(
        dio.get<dynamic>(protectedPath),
        throwsA(isA<DioException>()),
      );

      expect(tokens.getAccessToken(), 'expired-access');
      expect(tokens.getRefreshToken(), 'the-refresh-token');
      expect(tokens.hasAccessToken, isTrue);
    });

    test('a 500 on refresh leaves the tokens in place', () async {
      final Dio dio = buildWiredDio(refreshStatus: 500);

      await expectLater(
        dio.get<dynamic>(protectedPath),
        throwsA(isA<DioException>()),
      );

      expect(tokens.hasAccessToken, isTrue);
    });
  });

  group('a refused refresh token does end the session', () {
    test('a 401 on refresh clears the tokens and fires the hook', () async {
      bool hookFired = false;
      TokenRefreshInterceptor.onSessionExpired = () async {
        hookFired = true;
      };

      final Dio dio = buildWiredDio(refreshStatus: 401);

      // The screen that still shows the failure reads why, not the server's
      // "Unauthenticated." (QA-003 A13).
      await expectLater(
        dio.get<dynamic>(protectedPath),
        throwsA(
          isA<DioException>().having(
            (DioException e) => ApiErrorHandler.messageForDio(e),
            'message',
            LangKeys.sessionExpiredKey,
          ),
        ),
      );

      expect(tokens.getAccessToken(), isNull);
      expect(tokens.getRefreshToken(), isNull);
      expect(hookFired, isTrue);
    });

    test('a 200 carrying no token pair is treated as a refusal', () async {
      final Dio dio = buildWiredDio(
        refreshStatus: 200,
        refreshBody: <String, dynamic>{'data': <String, dynamic>{}},
      );

      await expectLater(
        dio.get<dynamic>(protectedPath),
        throwsA(isA<DioException>()),
      );

      expect(tokens.hasAccessToken, isFalse);
    });
  });

  test('a successful refresh stores the new pair', () async {
    // The protected endpoint 401s once, the refresh succeeds, the replay hits
    // the same stub and 401s again — which is fine: this asserts the tokens
    // were rotated, not that the replay succeeded.
    final Dio dio = buildWiredDio(
      refreshStatus: 200,
      refreshBody: <String, dynamic>{
        'data': <String, dynamic>{
          'access_token': 'fresh-access',
          'refresh_token': 'fresh-refresh',
        },
      },
    );

    await expectLater(
      dio.get<dynamic>(protectedPath),
      throwsA(isA<DioException>()),
    );

    expect(tokens.getAccessToken(), 'fresh-access');
    expect(tokens.getRefreshToken(), 'fresh-refresh');
  });

  test(
    'a photo upload refreshes and replays with the photo (QA-003 A14)',
    () async {
      // The multipart body is a one-shot stream the first attempt spends.
      // Uploads used to skip the refresh, so an expired token made every
      // profile-photo save say "Unauthenticated.".
      final Directory dir = Directory.systemTemp.createTempSync('a14_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final File photo = File('${dir.path}/avatar.jpg')
        ..writeAsStringSync('PHOTO-BYTES');

      final List<String> uploads = <String>[];
      final Dio refreshDio = Dio()
        ..httpClientAdapter = _StubAdapter(
          (RequestOptions options, _) => _json(<String, dynamic>{
            'data': <String, dynamic>{
              'access_token': 'fresh-access',
              'refresh_token': 'fresh-refresh',
            },
          }, 200),
        );
      final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _StubAdapter((
          RequestOptions options,
          String body,
        ) {
          uploads.add(body);
          return options.headers['Authorization'] == 'Bearer fresh-access'
              ? _json(<String, dynamic>{'data': <String, dynamic>{}}, 200)
              : _json(<String, dynamic>{'message': 'Unauthenticated.'}, 401);
        });
      dio.interceptors
        ..add(AuthTokenInterceptor())
        ..add(TokenRefreshInterceptor(dio, refreshDio: refreshDio));

      final Response<dynamic> response = await dio.post<dynamic>(
        '/api/v1/user/profile',
        data: FormData.fromMap(<String, dynamic>{
          'name': 'Sara',
          'avatar': await MultipartFile.fromFile(
            photo.path,
            filename: 'avatar.jpg',
          ),
        }),
      );

      expect(response.statusCode, 200);
      expect(uploads, hasLength(2));
      expect(uploads.last, contains('PHOTO-BYTES'));
      expect(uploads.last, contains('Sara'));
    },
  );
}
