import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';








class CacheException implements Exception {

  static const String saveGuestSessionFailedMessage =
      LangKeys.saveGuestSessionFailedKey;


  static const String saveUserSessionFailedMessage =
      LangKeys.saveUserSessionFailedKey;


  static const String clearUserSessionFailedMessage =
      LangKeys.clearUserSessionFailedKey;



  static const String ordersCacheStateFailedMessage =
      LangKeys.ordersCacheStateFailedKey;

  final String message;

  const CacheException(this.message);

  @override
  String toString() => message;
}
