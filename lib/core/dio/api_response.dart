import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';

/// Unwraps an API [response] into its body map, or a [Failure] saying why it is
/// not usable. The one place every repo decides "did this request succeed?".
///
/// It exists because the hand-written version of this check was wrong in the
/// same two ways in about twenty repos:
///
/// * **`response.data as Map<String, dynamic>` before anything is verified.** A
///   `2xx` whose body is not a JSON object — a `204 No Content`, an empty body,
///   or a bare JSON array — made that cast throw a raw `_TypeError` that reached
///   the user as an untranslated Dart error string. (A *non*-2xx never gets this
///   far: no `validateStatus` is overridden anywhere, so Dio's default turns
///   every non-2xx into a `DioException` the caller's `on DioException` branch
///   handles.) Here the body is shape-checked, never cast.
///
/// * **`if (response.statusCode != 200)`.** Since only a 2xx can reach that
///   line, its sole effect was to reject `201 Created`, `202 Accepted` and
///   `204 No Content` as failures. That is the bug that made every successful
///   wallet top-up report as failed. Here the whole 2xx range succeeds.
///
/// Set [requireSuccessFlag] on an endpoint whose envelope carries `success`, to
/// treat an explicit `success: false` on a 2xx as a failure. It is off by
/// default so a repo that never checked the flag does not silently start to.
///
/// Note what "explicit" means: an **absent** flag is still a success. A `204 No
/// Content` carries no body and therefore no flag, and demanding one there would
/// report a successful delete as a failure — which is precisely what used to
/// make a successful favourite-removal show an error toast.
Either<Failure, Map<String, dynamic>> readApiResponse(
  Response<dynamic> response, {
  bool requireSuccessFlag = false,
}) {
  final dynamic raw = response.data;
  final Map<String, dynamic> body = raw is Map<String, dynamic>
      ? raw
      : const <String, dynamic>{};

  final int statusCode = response.statusCode ?? 0;
  final bool hasSuccessStatus = statusCode >= 200 && statusCode < 300;
  final bool hasSuccessFlag =
      !requireSuccessFlag || (body['success'] as bool? ?? true);

  if (!hasSuccessStatus || !hasSuccessFlag) {
    return Left<Failure, Map<String, dynamic>>(
      Failure(ApiErrorHandler.extractErrorMessage(body)),
    );
  }

  return Right<Failure, Map<String, dynamic>>(body);
}

/// The envelope's `data` object, or an empty one when it is missing or not an
/// object. An empty list page can come as `"data": []`, and the `Map` cast that
/// used to read it threw — the catch-all then reported "server connection
/// failed" where the screen should have said there is nothing here (BUG-003).
Map<String, dynamic> responseData(Map<String, dynamic> body) {
  final dynamic data = body['data'];
  return data is Map<String, dynamic> ? data : <String, dynamic>{};
}
