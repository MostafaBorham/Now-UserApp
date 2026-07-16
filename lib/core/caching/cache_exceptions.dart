import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// Thrown by feature cache services when a cache read/write operation fails
/// (the caching counterpart of `DioException`).
///
/// [message] follows the same contract as `Failure.message`: a `LangKeys`
/// key or a raw human-readable message — callers apply `.tr()`, which
/// leaves non-key strings untouched. Reusable message keys are declared here
/// so cache services never hard-code error strings.
class CacheException implements Exception {
  /// Message key used when persisting the guest session fails.
  static const String saveGuestSessionFailedMessage =
      LangKeys.saveGuestSessionFailedKey;

  final String message;

  const CacheException(this.message);

  @override
  String toString() => message;
}