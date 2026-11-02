import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/token_refresh_interceptor.dart';

/// The shared [Dio], made so a read the app repeats in quick succession reaches
/// the server once.
///
/// Opening and closing a sheet that loads on open (the wallet's my-cards sheet)
/// sent one request per open, until the endpoint's rate limit answered `429`.
/// Every read now goes through two checks first:
///
/// * **in flight** — an identical read already on its way is joined, not sent
///   again;
/// * **just answered** — an identical read answered successfully less than
///   [reuseWindow] ago gets that same answer back.
///
/// "Identical" is the same method, URL with query, headers, body, response type
/// and session (see [_keyOf]). A read is a `GET`, or a request marked with
/// [readOnlyFlag]. Anything else is a write: once it finishes, everything
/// remembered is dropped, so the refetch that follows a write always reaches the
/// server. A failure is never reused, so a retry is always a real one. A
/// pull-to-refresh drops the remembered answers too ([forgetAnswers]).
///
/// It wraps [fetch], outside the interceptors, so it sees each request's final
/// outcome — after a token refresh and replay, not the `401` before it.
class DedupingDio extends DioForNative {
  DedupingDio([super.baseOptions]);

  /// How long a successful read is answered from memory. However fast someone
  /// taps, the tightest read limit the app hits (saved cards, 60 a minute) sees
  /// at most 20; and nothing shown is more than a moment older than a fetch.
  static const Duration reuseWindow = Duration(seconds: 3);

  /// `true` under this key in a request's `extra` makes a non-`GET` request
  /// that changes nothing (checkout's preview) a read.
  static const String readOnlyFlag = 'deduping_dio_read_only';

  final TokenCacheService _tokenCache = TokenCacheService();
  final Map<String, Future<Response<dynamic>>> _inFlight =
      <String, Future<Response<dynamic>>>{};
  final Map<String, ({Response<dynamic> response, DateTime at})> _answered =
      <String, ({Response<dynamic> response, DateTime at})>{};

  /// Bumped by every write, so a read sent before one is not remembered after.
  int _writes = 0;

  /// Drops the remembered answers, so the next reads go to the server.
  void forgetAnswers() => _answered.clear();

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    final bool isRead =
        requestOptions.method == 'GET' ||
        requestOptions.extra[readOnlyFlag] == true;
    if (!isRead) {
      try {
        return await super.fetch<T>(requestOptions);
      } finally {
        _writes++;
        _inFlight.clear();
        _answered.clear();
      }
    }

    // A token-refresh replay is the original read sent again from inside its
    // own fetch. Today the fresh token keeps its key apart from the original's;
    // this keeps it from ever waiting on itself if the key changes.
    if (requestOptions.extra[TokenRefreshInterceptor.retriedFlag] == true) {
      return super.fetch<T>(requestOptions);
    }

    final String key = _keyOf<T>(requestOptions);
    final DateTime now = DateTime.now();
    _answered.removeWhere(
      (_, ({Response<dynamic> response, DateTime at}) answer) =>
          now.difference(answer.at) >= reuseWindow,
    );
    final Response<dynamic>? answered = _answered[key]?.response;
    if (answered != null) return answered as Response<T>;

    final Future<Response<dynamic>>? inFlight = _inFlight[key];
    if (inFlight != null) return _join<T>(inFlight, requestOptions);

    final int writes = _writes;
    final Future<Response<T>> request = super.fetch<T>(requestOptions);
    _inFlight[key] = request;
    try {
      final Response<T> response = await request;
      if (writes == _writes) {
        _answered[key] = (response: response, at: DateTime.now());
      }
      return response;
    } finally {
      if (identical(_inFlight[key], request)) _inFlight.remove(key);
    }
  }

  /// Waits on [inFlight] for a caller that sent the same read, still honouring
  /// that caller's own cancel token. When the original was cancelled by *its*
  /// caller (a screen closing), this one is sent for real instead.
  Future<Response<T>> _join<T>(
    Future<Response<dynamic>> inFlight,
    RequestOptions requestOptions,
  ) async {
    final CancelToken? cancelToken = requestOptions.cancelToken;
    try {
      final Response<dynamic> response = await (cancelToken == null
          ? inFlight
          : Future.any(<Future<Response<dynamic>>>[
              inFlight,
              cancelToken.whenCancel.then<Response<dynamic>>(
                (DioException cancel) => throw cancel,
              ),
            ]));
      return response as Response<T>;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel &&
          !(cancelToken?.isCancelled ?? false)) {
        return fetch<T>(requestOptions);
      }
      rethrow;
    }
  }

  /// The session is part of the key because a forced logout clears the tokens
  /// without a write passing through here — a guest must never be handed the
  /// signed-out user's answer.
  String _keyOf<T>(RequestOptions requestOptions) => <Object?>[
    T,
    requestOptions.method,
    requestOptions.uri,
    requestOptions.responseType,
    requestOptions.headers,
    _tokenCache.getAccessToken() ?? _tokenCache.getGuestToken(),
    if (requestOptions.data != null) jsonEncode(requestOptions.data),
  ].join('\n');
}
