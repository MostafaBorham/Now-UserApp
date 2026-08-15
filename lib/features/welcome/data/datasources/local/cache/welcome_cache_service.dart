import 'dart:convert';

import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Local caching operations of the welcome feature.
///
/// The caching counterpart of `WelcomeApiService`: raw reads/writes against
/// [SharedPrefManager] only, so the repository never touches the cache
/// mechanism directly. Read/write failures surface as [CacheException] for
/// the repository to map into a `Failure`.
class WelcomeCacheService {
  /// Persists the auth token under [CacheKeys.token] as a JSON-encoded map:
  /// `{'token': token, 'isGuest': isGuest}`.
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
      throw const CacheException(CacheException.saveGuestSessionFailedMessage);
    }
  }

  /// Reads the cached token map (`{'token': String, 'isGuest': bool}`),
  /// returning an empty map when nothing is stored yet. A genuine cache
  /// read error is rethrown as a [CacheException] so the repository can
  /// surface it as a `Failure`.
  Map<String, dynamic> getToken() {
    try {
      final String? raw = SharedPrefManager.getString(CacheKeys.token);
      if (raw == null || raw.isEmpty) return const <String, dynamic>{};
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const CacheException(CacheException.readGuestSessionFailedMessage);
    }
  }
}
