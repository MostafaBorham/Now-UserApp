import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// Turns a point on the map into a partially filled [AddressModel].
///
/// The device-local half of the address data layer: the platform geocoder plays
/// the role the API service plays for the remote half, and this repo owns the
/// same `Either<Failure, T>` contract as the rest.
class GeocodingRepo {
  GeocodingRepo({
    Future<bool> Function()? isConnected,
    Future<Placemark?> Function(LatLng location)? placemarkAt,
  }) : _isConnected = isConnected ?? (() => ConnectionChecker.isConnected),
       _placemarkAt = placemarkAt ?? LocationManager.getAddressFromLocation;

  final Future<bool> Function() _isConnected;
  final Future<Placemark?> Function(LatLng location) _placemarkAt;

  /// Reverse-geocodes [location] into the address fields the details form
  /// prefills — everything the user cannot be expected to type.
  ///
  /// The platform geocoder needs the network. Offline it failed — after up to
  /// its 8 s timeout — and the map told the user to move the pin, as if the
  /// point were the problem. So the connection is checked first, and again
  /// when no placemark comes back, in case it dropped during the lookup:
  /// either way the user is told to check their connection.
  ///
  /// `Left(failedToGetAddress)` only when online and the platform returns no
  /// placemark at all, which is what the map treats as "pick another point".
  Future<Either<Failure, AddressModel>> addressAt(LatLng location) async {
    if (!await _isConnected()) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    final Placemark? placemark = await _placemarkAt(location);

    if (placemark == null) {
      return Left(
        Failure(
          await _isConnected()
              ? LangKeys.failedToGetAddress
              : LangKeys.noInternetConnectionKey,
        ),
      );
    }

    return Right(AddressModel.fromPlacemark(placemark, location));
  }
}
