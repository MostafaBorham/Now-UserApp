import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/datasources/remote/api/profile_endpoints.dart';

/// Raw API calls for the personal_information feature.
///
/// Each method only performs the request and returns the Dio [Response];
/// parsing and error handling live in the repository. The Sanctum bearer token
/// is attached automatically by the shared `AuthTokenInterceptor`.
///
/// Cancellation is encapsulated here: every request carries the token of
/// [_canceller], and callers only see the plain [cancelRequests] method.
class ProfileApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getProfile() {
    return _dio.get(ProfileEndpoints.profile, cancelToken: _canceller.token);
  }

  Future<Response> updateProfile(Map<String, dynamic> body) {
    return _dio.put(
      ProfileEndpoints.profile,
      data: body,
      cancelToken: _canceller.token,
    );
  }

  /// Update with an avatar change. Multipart requires POST (PHP can't parse
  /// multipart on PUT), so the whole update — text [fields] plus the [avatar]
  /// file or [removeAvatar] flag — goes through the POST alias.
  ///
  /// [fields] may contain nulls: dio writes a null field as an empty string,
  /// which is how "the user cleared this" survives the multipart encoding. That
  /// keeps this path's semantics identical to the JSON one.
  Future<Response> updateProfileMultipart({
    required Map<String, dynamic> fields,
    File? avatar,
    bool removeAvatar = false,
  }) async {
    final FormData form = FormData.fromMap({
      ...fields,
      if (removeAvatar) 'remove_avatar': '1',
      // Read off the UI isolate: the sync variant blocks the frame for as long
      // as it takes to pull a multi-megabyte photo off disk.
      if (avatar != null)
        'avatar': await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.uri.pathSegments.last,
        ),
    });

    return _dio.post(
      ProfileEndpoints.profile,
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
      cancelToken: _canceller.token,
    );
  }
}
