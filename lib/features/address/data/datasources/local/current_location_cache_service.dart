import 'dart:convert';

import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

class CurrentLocationCacheService {
  AddressModel? getCurrentLocation() {
    final String? raw = SharedPrefManager.getString(CacheKeys.currentLocation);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return AddressModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCurrentLocation(AddressModel address) async {
    await SharedPrefManager.setString(
      CacheKeys.currentLocation,
      jsonEncode(address.toJson()),
    );
  }
}
