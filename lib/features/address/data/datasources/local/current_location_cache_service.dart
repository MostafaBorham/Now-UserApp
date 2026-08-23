import 'dart:convert';

import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// Local store for the device's current location, reverse-geocoded into an
/// [AddressModel] and persisted as JSON under [CacheKeys.currentLocation].
///
/// This is the app-wide "current location" the splash guarantees is non-null
/// before the app is entered, and the home header reads as its default delivery
/// address. Reads are tolerant — a cold or corrupt cache returns `null` rather
/// than throwing — so nothing downstream ever crashes on a missing location.
class CurrentLocationCacheService {
  /// The cached current location, or `null` when nothing valid is stored yet.
  AddressModel? getCurrentLocation() {
    final String? raw = SharedPrefManager.getString(CacheKeys.currentLocation);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return AddressModel.fromJson(decoded);
    } catch (_) {
      // Corrupt/legacy payload — treat as no cached location.
      return null;
    }
  }

  /// Persists [address] as the current location. Best-effort: a failed write
  /// simply leaves the previous value in place.
  Future<void> saveCurrentLocation(AddressModel address) async {
    await SharedPrefManager.setString(
      CacheKeys.currentLocation,
      jsonEncode(address.toJson()),
    );
  }
}
