import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Attaches the cached token to the `X-Guest-Token` header of every request.
///
/// The token is read straight from the cache on each request (never through a
/// feature data source), so the header always reflects the latest value — the
/// guest token before login, and the user token after `AuthRepo.verifyOtp`
/// overwrites it. When no token is cached yet (e.g. the guest-token request
/// itself), the header is simply omitted.
class AuthTokenInterceptor extends Interceptor {
  static const String _headerKey = 'X-Guest-Token';

  /// Flag in `RequestOptions.extra`: when `true`, the `X-Guest-Token` header
  /// is not attached (e.g. the logout request authenticates with a `Bearer`
  /// token only).
  static const String skipGuestTokenKey = 'skipGuestToken';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final bool skip = options.extra[skipGuestTokenKey] as bool? ?? false;
    final String token = _readCachedToken();
    if (!skip && token.isNotEmpty) {
      options.headers[_headerKey] = token;
    }
    handler.next(options);
  }

  /// Reads the `token` value out of the cached `{'token', 'isGuest'}` map,
  /// returning an empty string when nothing is stored or the cache is
  /// malformed. Never throws — a bad cache must not block the request.
  String _readCachedToken() {
    final String? raw = SharedPrefManager.getString(CacheKeys.token);
    if (raw == null || raw.isEmpty) return '';
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return map[CacheKeys.tokenValue] as String? ?? '';
    } catch (_) {
      return '';
    }
  }
}
