import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/current_location_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

/// The delivery address currently shown on the home page — the one the header
/// displays and the delivery-address sheet opens on, highlighted in its list
/// with the map pin on it.
///
/// Until the user confirms something in the sheet this is the signed-in user's
/// **default saved address**; with none (a guest, or a user with no saved
/// address) it falls back to the cached current location, which may be empty.
/// The sheet overwrites it when the user confirms another address.
///
/// It watches [defaultAddressProvider], so it re-seeds whenever the default
/// changes: after a login from a still-mounted shell (which is why it cannot be
/// read once at creation), after logout, and when the user sets a different
/// default elsewhere. It watches [currentLocationProvider] too, so a location
/// found on resume or after a session change reaches the header. Nothing is
/// persisted — each launch starts from the default again, by product decision.
final homeAddressProvider = StateProvider.autoDispose<AddressModel?>((ref) {
  final AddressModel? defaultAddress = ref
      .watch(defaultAddressProvider)
      .valueOrNull;
  ref.watch(currentLocationProvider);

  return defaultAddress ?? CurrentLocationCacheService().getCurrentLocation();
});
