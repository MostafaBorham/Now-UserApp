import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

class TokenCacheService {

  String? getGuestToken() => SharedPrefManager.getString(CacheKeys.guestToken);

  Future<void> saveGuestToken(String token) async {
    final bool saved =
        await SharedPrefManager.setString(CacheKeys.guestToken, token);
    if (!saved) {
      throw const CacheException(CacheException.saveGuestSessionFailedMessage);
    }
  }


  String? getAccessToken() =>
      SharedPrefManager.getString(CacheKeys.accessToken);

  Future<void> saveAccessToken(String token) async {
    final bool saved =
        await SharedPrefManager.setString(CacheKeys.accessToken, token);
    if (!saved) {
      throw const CacheException(CacheException.saveUserSessionFailedMessage);
    }
  }


  String? getRefreshToken() =>
      SharedPrefManager.getString(CacheKeys.refreshToken);

  Future<void> saveRefreshToken(String token) async {
    final bool saved =
        await SharedPrefManager.setString(CacheKeys.refreshToken, token);
    if (!saved) {
      throw const CacheException(CacheException.saveUserSessionFailedMessage);
    }
  }


  Future<void> saveUserTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  bool get hasAccessToken => (getAccessToken() ?? '').isNotEmpty;

  bool get hasGuestToken => (getGuestToken() ?? '').isNotEmpty;


  Future<void> clearUserTokens() async {
    final bool accessRemoved =
        await SharedPrefManager.remove(CacheKeys.accessToken);
    final bool refreshRemoved =
        await SharedPrefManager.remove(CacheKeys.refreshToken);
    if (!accessRemoved || !refreshRemoved) {
      throw const CacheException(CacheException.clearUserSessionFailedMessage);
    }
  }

  Future<void> clearGuestToken() async {
    final bool removed =
        await SharedPrefManager.remove(CacheKeys.guestToken);
    if (!removed) {
      throw const CacheException(CacheException.clearUserSessionFailedMessage);
    }
  }
}
