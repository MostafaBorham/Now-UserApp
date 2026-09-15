import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_api_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';











class AddressRepo {




  AddressRepo({AddressApiService? api, Future<bool> Function()? isConnected})
      : _addressApiService = api ?? AddressApiService(),
        _isConnected = isConnected ?? (() => ConnectionChecker.isConnected);

  final AddressApiService _addressApiService;
  final Future<bool> Function() _isConnected;

  void cancelRequests() => _addressApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<AddressModel>>> getMyAddresses({
    required int page,
  }) {
    return _fetch(
      () => _addressApiService.getMyAddresses(page: page),
      (Map<String, dynamic> body) {
        final Map<String, dynamic> data =
            body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

        final List<dynamic> rawAddresses =
            data['addresses'] as List<dynamic>? ?? <dynamic>[];

        return PaginationModel<AddressModel>.fromJson(
          data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{},
          rawAddresses
              .map(
                (dynamic e) =>
                    AddressModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );
      },
    );
  }

  Future<Either<Failure, AddressModel>> addAddress({
    required AddressModel address,
  }) {
    return _fetch(
      () => _addressApiService.addAddress(address: address),
      _address,
    );
  }

  Future<Either<Failure, AddressModel>> editAddress({
    required int addressId,
    required AddressModel address,
  }) {
    return _fetch(
      () => _addressApiService.editAddress(
        addressId: addressId,
        address: address,
      ),
      _address,
    );
  }

  Future<Either<Failure, AddressModel>> getDefaultAddress() {
    return _fetch(_addressApiService.getDefaultAddress, _address);
  }

  Future<Either<Failure, AddressModel>> setDefaultAddress({
    required int addressId,
  }) {
    return _fetch(
      () => _addressApiService.setDefaultAddress(addressId: addressId),
      _address,
    );
  }




  Future<Either<Failure, Unit>> deleteAddress({required int addressId}) {
    return _fetch(
      () => _addressApiService.deleteAddress(addressId: addressId),
      (_) => unit,
    );
  }











  Future<Either<Failure, T>> _fetch<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic> body) parse,
  ) async {
    if (!await _isConnected()) {
      return Left<Failure, T>(
        const Failure(LangKeys.noInternetConnectionKey),
      );
    }

    try {
      final Response response = await request();



      final dynamic raw = response.data;
      final Map<String, dynamic> body =
          raw is Map<String, dynamic> ? raw : <String, dynamic>{};

      final int statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        return Left<Failure, T>(
          Failure(ApiErrorHandler.extractErrorMessage(body)),
        );
      }

      return Right<Failure, T>(parse(body));
    } on DioException catch (exception) {
      final Response<dynamic>? response = exception.response;






      if (response == null) {
        return Left<Failure, T>(
          const Failure(LangKeys.serverConnectionFailedKey),
        );
      }

      final dynamic data = response.data;
      return Left<Failure, T>(
        Failure(
          ApiErrorHandler.extractErrorMessage(
            data is Map<String, dynamic> ? data : null,
          ),
        ),
      );
    } catch (_) {

      return Left<Failure, T>(
        const Failure(LangKeys.serverConnectionFailedKey),
      );
    }
  }


  static AddressModel _address(Map<String, dynamic> body) {
    final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data['address'] as Map<String, dynamic>?);
  }
}
