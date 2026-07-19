import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Authenticates every outgoing request from the cached session, with no
/// per-request configuration needed anywhere in the app.
///
/// On each request the cached `{'token', 'isGuest'}` map is read straight from
/// the cache (never through a feature data source), so the header always
/// reflects the latest session:
///
/// * `isGuest == true`  → `X-Guest-Token: <token>` (the guest session)
/// * `isGuest == false` → `Authorization: Bearer <token>` (the logged-in user)
///
/// The token flips from the guest token to the user token automatically once
/// `AuthRepo.verifyOtp` overwrites the cache. When no token is cached yet (e.g.
/// the guest-token request itself), no auth header is attached.
class AuthTokenInterceptor extends Interceptor {
  static const String _guestHeaderKey = 'X-Guest-Token';
  static const String _authHeaderKey = 'Authorization';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final _Session session = _readCachedSession();
    if (session.token.isNotEmpty) {
      if (session.isGuest) {
        options.headers[_guestHeaderKey] = session.token;
      } else {
        options.headers[_authHeaderKey] = 'Bearer ${session.token}';
      }
    }
    handler.next(options);
  }

  /// Reads the cached `{'token', 'isGuest'}` map, returning an empty-token
  /// session when nothing is stored or the cache is malformed. Never throws —
  /// a bad cache must not block the request.
  _Session _readCachedSession() {
    final String? raw = SharedPrefManager.getString(CacheKeys.token);
    if (raw == null || raw.isEmpty) return const _Session('', false);
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return _Session(
        map[CacheKeys.tokenValue] as String? ?? '',
        map[CacheKeys.isGuest] as bool? ?? false,
      );
    } catch (_) {
      return const _Session('', false);
    }
  }
}

/// The cached session values relevant to authenticating a request.
class _Session {
  const _Session(this.token, this.isGuest);

  final String token;
  final bool isGuest;
}
