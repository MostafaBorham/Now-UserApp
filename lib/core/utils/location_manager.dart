import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

abstract class LocationManager {
  static Future<Placemark?> getAddressFromLocation(LatLng location) async {
    try {
      final addresses = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      return addresses.firstOrNull;
    } catch (_) {


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


  static Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();








  static Future<bool> requestService() async {
    try {
      return await loc.Location().requestService();
    } catch (_) {


      return isLocationServiceEnabled();
    }
  }




  static Future<LatLng?> getCurrentLatLng() async {
    final bool granted = await requestPermissions();
    if (!granted) return null;

    try {
      final Position current = await Geolocator.getCurrentPosition();
      return LatLng(current.latitude, current.longitude);
    } catch (_) {

    }

    try {
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) return LatLng(last.latitude, last.longitude);
    } catch (_) {}

    return null;
  }
}
