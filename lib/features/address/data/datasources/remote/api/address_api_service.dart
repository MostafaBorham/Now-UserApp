import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_endpoints.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';










class AddressApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> getMyAddresses({required int page}) {
    return _dio.get(
      AddressEndpoints.addresses,
      queryParameters: AddressEndpoints.myAddressesQuery(page),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> addAddress({required AddressModel address}) {
    return _dio.post(
      AddressEndpoints.addresses,
      data: address.toRequestJson(),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> editAddress({
    required int addressId,
    required AddressModel address,
  }) {
    return _dio.put(
      AddressEndpoints.editAddress(addressId),
      data: address.toRequestJson(),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getDefaultAddress() {
    return _dio.get(
      AddressEndpoints.defaultAddress,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> setDefaultAddress({required int addressId}) {
    return _dio.put(
      AddressEndpoints.setDefaultAddress(addressId),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> deleteAddress({required int addressId}) {
    return _dio.delete(
      AddressEndpoints.deleteAddress(addressId),
      cancelToken: _canceller.token,
    );
  }
}
