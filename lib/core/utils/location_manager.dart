import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

enum LocationPermissionStatus { granted, denied, deniedForever }

abstract class LocationManager {
  /// How long to wait for a device fix before giving up on it.
  ///
  /// Without a limit `getCurrentPosition` waits indefinitely for a satellite
  /// fix, and the splash blocks on it — so a phone indoors or underground could
  /// sit on the loading screen forever with no way past. Giving up hands
  /// control back to the caller, which falls back to the last known position
  /// and otherwise goes without one.
  static const Duration _fixTimeout = Duration(seconds: 10);

  /// Reverse geocoding needs the network, so it gets its own ceiling for the
  /// same reason.
  static const Duration _geocodeTimeout = Duration(seconds: 8);

  static Future<Placemark?> getAddressFromLocation(LatLng location) async {
    try {
      final addresses = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      ).timeout(_geocodeTimeout);
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

  static Future<LocationPermissionStatus> requestPermissionStatus() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return _statusOf(permission);
    } catch (_) {
      return LocationPermissionStatus.denied;
    }
  }

  static Future<LocationPermissionStatus> currentPermissionStatus() async {
    try {
      return _statusOf(await Geolocator.checkPermission());
    } catch (_) {
      return LocationPermissionStatus.denied;
    }
  }

  static LocationPermissionStatus _statusOf(LocationPermission permission) {
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return LocationPermissionStatus.granted;
    }
    return LocationPermissionStatus.denied;
  }

  static Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Whether the device's location service (GPS) is currently switched on.
  static Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Prompts the user to switch the location service on **in place**, via the
  /// native system prompt (the Google Play Services sheet on Android) — no trip
  /// to the settings app. Returns `true` when the service ends up enabled, and
  /// `false` when the user dismisses or refuses it.
  ///
  /// This is the one thing geolocator cannot do, so it delegates to the
  /// `location` package; everything else stays on geolocator.
  static Future<bool> requestService() async {
    try {
      return await loc.Location().requestService();
    } catch (_) {
      // Platform without an in-place prompt (e.g. iOS) or a plugin error: fall
      // back to reporting the current service state.
      return isLocationServiceEnabled();
    }
  }

  /// Best-effort device coordinates: a fresh fix first, falling back to the last
  /// known position. Returns `null` when permission is denied, the service is
  /// off, or no position can be resolved at all.
  static Future<LatLng?> getCurrentLatLng() async {
    final bool granted = await requestPermissions();
    if (!granted) return null;

    try {
      final Position current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: _fixTimeout),
      );
      return LatLng(current.latitude, current.longitude);
    } catch (_) {
      // Service off, no fix within [_fixTimeout], etc. — fall back to the last
      // known fix.
    }

    try {
      final Position? last = await Geolocator.getLastKnownPosition().timeout(
        _fixTimeout,
      );
      if (last != null) return LatLng(last.latitude, last.longitude);
    } catch (_) {}

    return null;
  }
}
