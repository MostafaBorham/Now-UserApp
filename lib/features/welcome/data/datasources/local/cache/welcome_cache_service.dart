import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Local caching operations of the welcome feature.
///
/// The caching counterpart of `WelcomeApiService`: raw reads/writes against
/// [SharedPrefManager] only, so the repository never touches the cache
/// mechanism directly. Write failures surface as [CacheException] for the
/// repository to map into a `Failure`.
class WelcomeCacheService {
  Future<void> saveGuestToken(String guestToken) async {
    final bool saved =
        await SharedPrefManager.setString(CacheKeys.guestToken, guestToken);
    if (!saved) {
      throw const CacheException(CacheException.saveGuestSessionFailedMessage);
    }
  }

  String? getGuestToken() => SharedPrefManager.getString(CacheKeys.guestToken);
}
