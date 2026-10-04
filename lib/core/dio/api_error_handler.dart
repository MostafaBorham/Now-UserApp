import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// Shared helpers for interpreting API error responses.
class ApiErrorHandler {
  ApiErrorHandler._();

  /// A key, not text: callers `.tr()` every failure message, so this reaches
  /// an Arabic user in Arabic.
  static const String _defaultMessage = LangKeys.somethingWentWrongKey;

  /// Extracts the failure message from a response body [Map]: the first field
  /// message of a validation error when there is one, else `message`.
  ///
  /// A 422's own `message` is a generic "Validation failed." — on the address
  /// form that was all the user got, with nothing to say which field. The
  /// field messages in `errors` are already localized by the backend.
  ///
  /// Falls back to a generic message key when the body is null or has no
  /// usable message.
  static String extractErrorMessage(Map<String, dynamic>? responseBody) {
    final String? fieldMessage = _firstFieldMessage(responseBody?['errors']);
    if (fieldMessage != null) return fieldMessage;

    final dynamic message = responseBody?['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    return _defaultMessage;
  }

  /// Laravel's shape: `{"field": ["message", …], …}`.
  static String? _firstFieldMessage(Object? errors) {
    if (errors is! Map || errors.isEmpty) return null;
    final Object? first = errors.values.first;
    final Object? message = first is List && first.isNotEmpty
        ? first.first
        : first;
    if (message is! String || message.trim().isEmpty) return null;
    return message;
  }
}
