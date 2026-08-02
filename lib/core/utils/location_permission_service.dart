import 'package:geolocator/geolocator.dart';

/// Handles requesting the device location permission.
///
/// Kept UI-agnostic: it only asks the OS for permission and reports back
/// whether access was granted, so callers decide what to do next.
abstract final class LocationPermissionService {
  /// Requests location access from the user and resolves once they respond
  /// (allow or refuse). Returns `true` only when access is granted.
  static Future<bool> request() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
