import 'dart:convert';

import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Local caching operations of the auth feature.
///
/// The caching counterpart of `AuthApiService`: raw writes against
/// [SharedPrefManager] only, so the repository never touches the cache
/// mechanism directly. Reading the token for outgoing requests is handled by
/// `AuthTokenInterceptor`; this service only persists it. Write failures
/// surface as [CacheException] for the repository to map into a `Failure`.
class AuthCacheService {
  /// Persists the auth token under [CacheKeys.token] as a JSON-encoded map:
  /// `{'token': token, 'isGuest': isGuest}` — overwriting whatever token
  /// (e.g. the guest token) was stored before.
  Future<void> saveToken({
    required String token,
    required bool isGuest,
  }) async {
    final bool saved = await SharedPrefManager.setString(
      CacheKeys.token,
      jsonEncode(<String, dynamic>{
        CacheKeys.tokenValue: token,
        CacheKeys.isGuest: isGuest,
      }),
    );
    if (!saved) {
      throw const CacheException(CacheException.saveUserSessionFailedMessage);
    }
  }

  /// Reads the `token` value out of the cached `{'token', 'isGuest'}` map,
  /// returning an empty string when nothing is stored or the cache is
  /// malformed. Never throws — used to authenticate the logout request.
  String getToken() {
    try {
      final String? raw = SharedPrefManager.getString(CacheKeys.token);
      if (raw == null || raw.isEmpty) return '';
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return map[CacheKeys.tokenValue] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Removes the cached session entirely, so the app falls back to a
  /// logged-out state. A removal failure surfaces as a [CacheException] for
  /// the repository to map into a `Failure`.
  Future<void> clearToken() async {
    final bool removed = await SharedPrefManager.remove(CacheKeys.token);
    if (!removed) {
      throw const CacheException(CacheException.clearUserSessionFailedMessage);
    }
  }
}
