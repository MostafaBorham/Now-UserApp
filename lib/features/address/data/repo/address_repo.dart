import 'package:dartz/dartz.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/repo/base_repo.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_api_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// All data operations of the address feature.
///
/// Every method returns `Either<Failure, T>` through [BaseRepo.guard], which
/// owns the connection check, the status check and the error mapping: `Left`
/// carries a user-facing message (a `LangKeys` key or a clean server message —
/// callers apply `.tr()`, which leaves non-key strings untouched), `Right`
/// carries the data.
class AddressRepo with BaseRepo {
  final AddressApiService _addressApiService = AddressApiService();

  void cancelRequests() => _addressApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<AddressModel>>> getMyAddresses({
    required int page,
  }) {
    return guard(
      () => _addressApiService.getMyAddresses(page: page),
      (Map<String, dynamic> data) {
        final Map<String, dynamic> paginationData =
            data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final List<dynamic> rawAddresses =
            data['addresses'] as List<dynamic>? ?? <dynamic>[];

        return PaginationModel<AddressModel>.fromJson(
          paginationData,
          rawAddresses
              .map(
                (dynamic e) =>
                    AddressModel.fromJson(e as Map<String, dynamic>?),
              )
              .toList(),
        );
      },
    );
  }

  Future<Either<Failure, AddressModel>> addAddress({
    required AddressModel address,
  }) {
    return guard(
      () => _addressApiService.addAddress(address: address),
      _parseAddress,
    );
  }

  Future<Either<Failure, AddressModel>> editAddress({
    required int addressId,
    required AddressModel address,
  }) {
    return guard(
      () => _addressApiService.editAddress(
        addressId: addressId,
        address: address,
      ),
      _parseAddress,
    );
  }

  Future<Either<Failure, AddressModel>> getDefaultAddress() {
    return guard(_addressApiService.getDefaultAddress, _parseAddress);
  }

  Future<Either<Failure, AddressModel>> setDefaultAddress({
    required int addressId,
  }) {
    return guard(
      () => _addressApiService.setDefaultAddress(addressId: addressId),
      _parseAddress,
    );
  }

  /// Every single-address endpoint answers with the address under the same key.
  static AddressModel _parseAddress(Map<String, dynamic> data) =>
      AddressModel.fromJson(data['address'] as Map<String, dynamic>?);
}
