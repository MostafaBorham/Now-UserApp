import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// Shared helpers for interpreting API error responses.
class ApiErrorHandler {
  ApiErrorHandler._();

  /// A key, not text: callers `.tr()` every failure message, so this reaches
  /// an Arabic user in Arabic.
  static const String _defaultMessage = LangKeys.somethingWentWrongKey;

  /// The message for a request Dio failed (QA-003, one rule for every repo):
  /// - no response at all — timeout, DNS, refused, dropped: the server was
  ///   never reached → `serverConnectionFailed`;
  /// - a 5xx or a proxy's 413 → `serverUnavailable`, never Laravel's bare
  ///   "Server Error" or a proxy's HTML page;
  /// - a 405 → the generic message, not "Method POST is not allowed…";
  /// - anything else → the server's own message ([extractErrorMessage]), read
  ///   from [body] when the caller decoded it (a plain-text request);
  /// - a 404 → [notFound] when the caller names what is missing (a deleted
  ///   order, product or store), never the server's English "not found".
  static String messageForDio(
    DioException exception, {
    Map<String, dynamic>? body,
    String? notFound,
  }) {
    final Response<dynamic>? response = exception.response;
    if (response == null) return LangKeys.serverConnectionFailedKey;
    final int status = response.statusCode ?? 0;
    if (status >= 500 || status == 413) return LangKeys.serverUnavailableKey;
    if (status == 405) return _defaultMessage;
    if (status == 404 && notFound != null) return notFound;
    final dynamic data = response.data;
    return extractErrorMessage(
      body ?? (data is Map<String, dynamic> ? data : null),
    );
  }

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
