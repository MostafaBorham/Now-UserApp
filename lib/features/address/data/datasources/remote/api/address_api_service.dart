import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_endpoints.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

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

  Future<Response> getMyAddresses({required int page}) {
    AddressEndpoints.page = page;
    return _dio.get(
      AddressEndpoints.addresses,
      queryParameters: AddressEndpoints.getMyAddressesQuery,
      cancelToken: _canceller.token,
    );
  }

  /// Creates a new address for the current user.
  ///
  /// The request body is shaped from [address], sending only the fields the
  /// backend accepts on creation (server-owned fields such as `id`,
  /// `user_id`, `full_address` and timestamps are omitted).
  Future<Response> addAddress({required AddressModel address}) {
    return _dio.post(
      AddressEndpoints.addresses,
      data: <String, dynamic>{
        'label': address.label?['en'],
        'phone': address.phone,
        'country': address.country,
        'city': address.city,
        'area': address.area,
        'street': address.street,
        'building_number': address.buildingNumber,
        'floor': address.floor,
        'apartment': address.apartment,
        'latitude': double.tryParse(address.latitude ?? ''),
        'longitude': double.tryParse(address.longitude ?? ''),
        'notes': address.notes,
        'is_default': address.isDefault ?? false,
      },
      cancelToken: _canceller.token,
    );
  }

  /// Updates the address identified by [addressId].
  ///
  /// The request body mirrors [addAddress]: only the client-owned fields are
  /// sent (server-owned fields such as `id`, `user_id`, `full_address` and
  /// timestamps are omitted).
  Future<Response> editAddress({
    required int addressId,
    required AddressModel address,
  }) {
    return _dio.put(
      AddressEndpoints.editAddress(addressId),
      data: <String, dynamic>{
        'label': address.label?['en'],
        'phone': address.phone,
        'country': address.country,
        'city': address.city,
        'area': address.area,
        'street': address.street,
        'building_number': address.buildingNumber,
        'floor': address.floor,
        'apartment': address.apartment,
        'latitude': double.tryParse(address.latitude ?? ''),
        'longitude': double.tryParse(address.longitude ?? ''),
        'notes': address.notes,
        'is_default': address.isDefault ?? false,
      },
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
}
