import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';






class GeocodingRepo {





  Future<Either<Failure, AddressModel>> addressAt(LatLng location) async {
    final Placemark? placemark = await LocationManager.getAddressFromLocation(
      location,
    );

    if (placemark == null) {
      return const Left(Failure(LangKeys.failedToGetAddress));
    }

    return Right(AddressModel.fromPlacemark(placemark, location));
  }
}
