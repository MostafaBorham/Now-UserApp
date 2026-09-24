import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// Shared helpers for interpreting API error responses.
class ApiErrorHandler {
  ApiErrorHandler._();

  /// A key, not text: callers `.tr()` every failure message, so this reaches
  /// an Arabic user in Arabic.
  static const String _defaultMessage = LangKeys.somethingWentWrongKey;

  /// Extracts the failure `message` from a response body [Map].
  ///
  /// Falls back to a generic message key when the body is null or has no
  /// usable `message` field.
  static String extractErrorMessage(Map<String, dynamic>? responseBody) {
    final dynamic message = responseBody?['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    return _defaultMessage;
  }
}
