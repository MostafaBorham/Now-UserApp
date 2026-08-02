import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationManager {

  static Future<Placemark?> getAddressFromLocation(LatLng location) async {
    try {
      final addresses = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      return addresses.isNotEmpty ? addresses.first : null;
    } catch (_) {
      return null;
    }
  }
}