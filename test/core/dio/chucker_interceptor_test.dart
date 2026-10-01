import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/chucker_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds each request until the test releases its path, so two requests can be
/// kept in flight at the same time.
class _GatedAdapter implements HttpClientAdapter {
  final Map<String, Completer<void>> gates = <String, Completer<void>>{};
  final Map<String, Completer<void>> started = <String, Completer<void>>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    started[options.path]!.complete();
    await gates[options.path]!.future;
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'path': options.path}),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('overlapping requests are recorded with their own start times',
      () async {
    // chucker_flutter's own interceptor keeps one start time for every request,
    // so `/b` starting would overwrite `/a`'s and both records would share it —
    // and that timestamp is the key chucker opens and deletes records by.
    final _GatedAdapter adapter = _GatedAdapter();
    for (final String path in <String>['/a', '/b']) {
      adapter.gates[path] = Completer<void>();
      adapter.started[path] = Completer<void>();
    }
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ChuckerInterceptor());

    final Future<Response<dynamic>> a = dio.get<dynamic>('/a');
    await adapter.started['/a']!.future;
    // A real gap, so the two start times cannot coincide by accident.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final Future<Response<dynamic>> b = dio.get<dynamic>('/b');
    await adapter.started['/b']!.future;

    adapter.gates['/a']!.complete();
    await a;
    adapter.gates['/b']!.complete();
    await b;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<dynamic> records =
        jsonDecode(prefs.getString('api_responses')!) as List<dynamic>;
    final Map<String, String> startedAt = <String, String>{
      for (final dynamic r in records)
        (r as Map<String, dynamic>)['path'] as String:
            r['requestTime'] as String,
    };

    expect(startedAt.keys, unorderedEquals(<String>['/a', '/b']));
    expect(startedAt['/a'], isNot(startedAt['/b']));
  });
}
