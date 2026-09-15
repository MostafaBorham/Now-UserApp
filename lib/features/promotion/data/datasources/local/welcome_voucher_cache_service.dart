import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';








class WelcomeVoucherCacheService {

  String? getWelcomeCode() {
    final String? code = SharedPrefManager.getString(
      CacheKeys.welcomeVoucherCode,
    );
    if (code == null || code.isEmpty) return null;
    return code;
  }



  Future<void> saveWelcomeCode(String code) async {
    await SharedPrefManager.setString(CacheKeys.welcomeVoucherCode, code);
  }
}
