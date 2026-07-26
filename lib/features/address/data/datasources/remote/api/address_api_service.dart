import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_endpoints.dart';

/// Raw API calls for the address feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class AddressApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getMyAddresses() {
    return _dio.get(
      AddressEndpoints.getMyAddresses,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getDefaultAddress() {
    return _dio.get(
      AddressEndpoints.getDefaultAddress,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> setDefaultAddress({required int addressId}) {
    return _dio.put(
      AddressEndpoints.setDefaultAddress(addressId),
      cancelToken: _canceller.token,
    );
  }
}
