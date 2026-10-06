import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_api_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// All data operations of the address feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
///
/// The connection check, status handling and error mapping live in [_fetch],
/// which also runs the parsing — so a payload in an unexpected shape fails the
/// same way a rejected request does, instead of throwing past the caller. Each
/// method below is left with nothing but the shape of its own response.
class AddressRepo {
  /// Both collaborators are injectable so the repo can be exercised without a
  /// live [Dio] singleton or a real connectivity probe — [ConnectionChecker]
  /// reaches the network, which a unit test cannot do. Production callers keep
  /// using `AddressRepo()` and get the real ones.
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

  /// The user's default address, or `null` when they have none. The backend
  /// answers that case with a 404 today and is asked to answer 200 with
  /// `data.address: null` (BUG-002, QA V2); both read as "no default", not an
  /// error. Parsed as nullable: `AddressModel.fromJson(null)` is an empty
  /// address, which the checkout card and the home header would show.
  Future<Either<Failure, AddressModel?>> getDefaultAddress() {
    return _fetch(
      _addressApiService.getDefaultAddress,
      (Map<String, dynamic> body) {
        final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
        final Map<String, dynamic>? address =
            data['address'] as Map<String, dynamic>?;
        return address == null ? null : AddressModel.fromJson(address);
      },
      onNotFound: () => null,
    );
  }

  Future<Either<Failure, AddressModel>> setDefaultAddress({
    required int addressId,
  }) {
    return _fetch(
      () => _addressApiService.setDefaultAddress(addressId: addressId),
      _address,
    );
  }

  /// Deletes the address with [addressId]. On success the response carries no
  /// data worth keeping (`data: []`, or no body at all on a `204`), so a plain
  /// [Unit] is returned; the caller shows its own localized success message.
  Future<Either<Failure, Unit>> deleteAddress({required int addressId}) {
    return _fetch(
      () => _addressApiService.deleteAddress(addressId: addressId),
      (_) => unit,
    );
  }

  /// Shared request envelope: connection check, non-2xx handling, parsing and
  /// error mapping.
  ///
  /// Any 2xx counts as success, not just 200 — a create answers `201` and a
  /// delete can answer `204` with no body at all, both of which used to be
  /// reported to the user as failures.
  ///
  /// [parse] runs inside the same guard as the request, so a payload in a shape
  /// we did not expect surfaces as a [Failure] rather than throwing out of the
  /// repo and into a snackbar as a raw Dart error string.
  ///
  /// [onNotFound], when given, answers a 404 instead of a failure.
  Future<Either<Failure, T>> _fetch<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic> body) parse, {
    T Function()? onNotFound,
  }) async {
    if (!await _isConnected()) {
      return Left<Failure, T>(
        const Failure(LangKeys.noInternetConnectionKey),
      );
    }

    try {
      final Response response = await request();

      // A `204` answers with no body; anything else unexpected is treated the
      // same way, so the status check below is what decides the outcome.
      final dynamic raw = response.data;
      final Map<String, dynamic> body =
          raw is Map<String, dynamic> ? raw : <String, dynamic>{};

      final int statusCode = response.statusCode ?? 0;
      if (statusCode == 404 && onNotFound != null) {
        return Right<Failure, T>(onNotFound());
      }
      if (statusCode < 200 || statusCode >= 300) {
        return Left<Failure, T>(
          Failure(ApiErrorHandler.extractErrorMessage(body)),
        );
      }

      return Right<Failure, T>(parse(body));
    } on DioException catch (exception) {
      final Response<dynamic>? response = exception.response;

      // No response at all means we never reached the server (DNS, timeout,
      // connection dropped, request cancelled). That is a different failure
      // from one the server answered with, so it gets its own key rather than
      // `ApiErrorHandler`'s generic one.
      if (response == null) {
        return Left<Failure, T>(
          const Failure(LangKeys.serverConnectionFailedKey),
        );
      }
      if (response.statusCode == 404 && onNotFound != null) {
        return Right<Failure, T>(onNotFound());
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
      // Never surface a raw exception string: it ends up in a snackbar.
      return Left<Failure, T>(
        const Failure(LangKeys.serverConnectionFailedKey),
      );
    }
  }

  /// The `data.address` object every single-address endpoint answers with.
  static AddressModel _address(Map<String, dynamic> body) {
    final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data['address'] as Map<String, dynamic>?);
  }
}
