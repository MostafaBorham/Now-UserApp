import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/datasources/remote/api/profile_endpoints.dart';









class ProfileApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


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








  Future<Response> updateProfileMultipart({
    required Map<String, dynamic> fields,
    File? avatar,
    bool removeAvatar = false,
  }) async {
    final FormData form = FormData.fromMap({
      ...fields,
      if (removeAvatar) 'remove_avatar': '1',


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
