import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  /// Reverse-geocodes [location] into the address fields the details form
  /// prefills — everything the user cannot be expected to type.
  ///
  /// `Left` when the platform returns no placemark at all, which is what the
  /// map treats as "pick another point".
  Future<Either<Failure, AddressModel>> addressAt(LatLng location) async {
    final Placemark? placemark = await LocationManager.getAddressFromLocation(
      location,
    );

    if (placemark == null) {
      return const Left(Failure(LangKeys.failedToGetAddress));
    }

    return Right(_compose(placemark, location));
  }

  /// The area is built from the most specific administrative parts the geocoder
  /// filled in, falling back to the place name when it filled in none.
  static AddressModel _compose(Placemark placemark, LatLng location) {
    final String area = <String?>[
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ].whereType<String>().where((String part) => part.isNotEmpty).join(' - ');

    return AddressModel(
      country: placemark.country,
      city: placemark.locality,
      area: area.isEmpty ? placemark.name : area,
      street: placemark.street,
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
    );
  }
}
