import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationManager {
  static Future<Placemark?> getAddressFromLocation(LatLng location) async {
    try {
      final addresses = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      return addresses.firstOrNull;
    } catch (_) {
      // No placemark for this point (no coverage, no connectivity, plugin
      // error). Callers turn a null into a user-facing failure.
      return null;
    }
  }

  static Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
