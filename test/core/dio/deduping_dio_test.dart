import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/dio/deduping_dio.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/auth_token_interceptor.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/token_refresh_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Counts what reaches the "server", answering after a short delay so two
/// requests can overlap. [status] decides the answer per request.
class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter({this.status});

  final int Function(RequestOptions options)? status;
  final List<String> hits = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    hits.add('${options.method} ${options.uri.path}');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'hit': hits.length}),
      status?.call(options) ?? 200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const String cards = '/api/v1/payment-methods/cards';

  late _CountingAdapter server;
  late Dio dio;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefManager.init();
    await TokenCacheService().saveUserTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    server = _CountingAdapter();
    dio = DedupingDio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = server;
  });

  test('a sheet opened twice at once sends one request', () async {
    final List<Response<dynamic>> answers = await Future.wait(
      <Future<Response<dynamic>>>[dio.get(cards), dio.get(cards)],
    );

    expect(server.hits, hasLength(1));
    expect(answers[1].data, answers[0].data);
  });

  test('a sheet reopened right after it loaded sends nothing new', () async {
    await dio.get(cards);
    await dio.get(cards);
    await dio.get(cards);

    expect(server.hits, hasLength(1));
  });

  test('a write in between makes the next read go to the server', () async {
    await dio.get(cards);
    await dio.delete('$cards/7');
    final Response<dynamic> afterDelete = await dio.get(cards);

    expect(server.hits, <String>['GET $cards', 'DELETE $cards/7', 'GET $cards']);
    expect(afterDelete.data, <String, dynamic>{'hit': 3});
  });

  test('a pull-to-refresh read goes to the server inside the window', () async {
    await dio.get(cards);
    (dio as DedupingDio).forgetAnswers();
    await dio.get(cards);

    expect(server.hits, hasLength(2));
  });

  test('a different query is a different read', () async {
    await dio.get(cards, queryParameters: <String, dynamic>{'page': 1});
    await dio.get(cards, queryParameters: <String, dynamic>{'page': 2});

    expect(server.hits, hasLength(2));
  });

  test('a failure is never reused, so a retry is real', () async {
    server = _CountingAdapter(status: (_) => 500);
    dio.httpClientAdapter = server;

    await expectLater(dio.get(cards), throwsA(isA<DioException>()));
    await expectLater(dio.get(cards), throwsA(isA<DioException>()));

    expect(server.hits, hasLength(2));
  });

  test('another session never gets this session\'s answer', () async {
    await dio.get(cards);
    await TokenCacheService().clearUserTokens();
    await dio.get(cards);

    expect(server.hits, hasLength(2));
  });

  test('a read marked read-only is shared even as a POST', () async {
    final Options readOnly = Options(
      extra: <String, dynamic>{DedupingDio.readOnlyFlag: true},
    );
    const Map<String, dynamic> body = <String, dynamic>{'address_id': 1};

    await dio.post('/preview', data: body, options: readOnly);
    await dio.post('/preview', data: body, options: readOnly);
    await dio.post(
      '/preview',
      data: <String, dynamic>{'address_id': 2},
      options: readOnly,
    );

    expect(server.hits, hasLength(2));
  });

  test('when the first caller cancels, the second still gets its answer',
      () async {
    final CancelToken leaving = CancelToken();
    final Future<Response<dynamic>> first = dio.get(
      cards,
      cancelToken: leaving,
    );
    final Future<Response<dynamic>> second = dio.get(cards);
    leaving.cancel();

    await expectLater(first, throwsA(isA<DioException>()));
    expect((await second).statusCode, 200);
  });

  test('a 401 is refreshed and replayed to an answer, not left hanging',
      () async {
    final Dio refreshDio = Dio()..httpClientAdapter = _PairAdapter();
    // 401 until the refresh lands, then 200.
    server = _CountingAdapter(
      status: (RequestOptions options) =>
          options.headers['Authorization'] == 'Bearer access' ? 401 : 200,
    );
    dio
      ..httpClientAdapter = server
      ..interceptors.addAll(<Interceptor>[
        AuthTokenInterceptor(),
        TokenRefreshInterceptor(dio, refreshDio: refreshDio),
      ]);

    final Response<dynamic> response = await dio
        .get(cards)
        .timeout(const Duration(seconds: 2));

    expect(response.statusCode, 200);
    expect(server.hits, hasLength(2));
  });
}

class _PairAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(<String, dynamic>{
      'data': <String, dynamic>{
        'access_token': 'fresh-access',
        'refresh_token': 'fresh-refresh',
      },
    }),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/json'],
    },
  );

  @override
  void close({bool force = false}) {}
}
