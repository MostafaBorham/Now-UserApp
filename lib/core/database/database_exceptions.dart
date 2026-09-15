import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';








class DatabaseException implements Exception {

  static const String readRecentSearchesFailedMessage =
      LangKeys.readRecentSearchesFailedKey;


  static const String saveRecentSearchesFailedMessage =
      LangKeys.saveRecentSearchesFailedKey;


  static const String clearRecentSearchesFailedMessage =
      LangKeys.clearRecentSearchesFailedKey;


  static const String readCachedOrdersFailedMessage =
      LangKeys.readCachedOrdersFailedKey;

  final String message;

  const DatabaseException(this.message);

  @override
  String toString() => message;
}
