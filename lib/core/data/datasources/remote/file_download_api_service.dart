import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';

/// Raw download of a file at a full URL, through the shared Dio so an
/// authenticated download route gets the session token (and its refresh).
class FileDownloadApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response<List<int>>> downloadBytes({required String url}) {
    return _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
      cancelToken: _canceller.token,
    );
  }
}
