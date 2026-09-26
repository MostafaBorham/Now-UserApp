import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// Thrown by feature cache services when a cache read/write operation fails
/// (the caching counterpart of `DioException`).
///
/// [message] follows the same contract as `Failure.message`: a `LangKeys`
/// key or a raw human-readable message — callers apply `.tr()`, which
/// leaves non-key strings untouched. Reusable message keys are declared here
/// so cache services never hard-code error strings.
class DatabaseException implements Exception {
  /// Message key used when reading the recent search keywords fails.
  static const String readRecentSearchesFailedMessage =
      LangKeys.readRecentSearchesFailedKey;

  /// Message key used when persisting the recent search keywords fails.
  static const String saveRecentSearchesFailedMessage =
      LangKeys.saveRecentSearchesFailedKey;

  /// Message key used when clearing the recent search keywords fails.
  static const String clearRecentSearchesFailedMessage =
      LangKeys.clearRecentSearchesFailedKey;

  final String message;

  const DatabaseException(this.message);

  @override
  String toString() => message;
}
