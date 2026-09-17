import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// The delivery address currently shown on the home page — the one the header
/// displays and the delivery-address sheet opens on.
///
/// Seeded from the guaranteed current location the splash caches (the default
/// location when the user never picked one), so it is non-null from the first
/// read. The sheet overwrites it when the user confirms another address.
final homeAddressProvider = StateProvider.autoDispose<AddressModel?>(
  (ref) => CurrentLocationCacheService().getCurrentLocation(),
);
