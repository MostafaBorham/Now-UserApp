import 'package:dio/dio.dart';










class RequestCanceller {
  CancelToken _token = CancelToken();


  CancelToken get token {
    if (_token.isCancelled) {
      _token = CancelToken();
    }
    return _token;
  }



  void cancel() {
    if (!_token.isCancelled) {
      _token.cancel();
    }
  }
}
