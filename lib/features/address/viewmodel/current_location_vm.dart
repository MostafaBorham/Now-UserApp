import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

enum CurrentLocationStatus { idle, resolving, ready, declined }

final currentLocationProvider =
    StateNotifierProvider<CurrentLocationViewModel, CurrentLocationStatus>(
  (Ref ref) => CurrentLocationViewModel(),
);

class CurrentLocationViewModel extends StateNotifier<CurrentLocationStatus> {
  CurrentLocationViewModel() : super(CurrentLocationStatus.idle);

  final CurrentLocationCacheService _cache = CurrentLocationCacheService();

  Future<void> resolve() async {
    state = CurrentLocationStatus.resolving;

    final AddressModel? cached = _cache.getCurrentLocation();
    bool serviceEnabled = await LocationManager.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (cached != null) {
        state = CurrentLocationStatus.ready;
        return;
      }
      serviceEnabled = await LocationManager.requestService();
      if (!mounted) return;
      if (!serviceEnabled) {
        state = CurrentLocationStatus.declined;
        return;
      }
    }

    final AddressModel? fresh = await _fetchAndCache();
    if (!mounted) return;
    state = (fresh != null || cached != null)
        ? CurrentLocationStatus.ready
        : CurrentLocationStatus.declined;
  }

  Future<AddressModel?> _fetchAndCache() async {
    final LatLng? location = await LocationManager.getCurrentLatLng();
    if (location == null) return null;

    final Placemark? placemark =
        await LocationManager.getAddressFromLocation(location);
    if (placemark == null) return null;

    final AddressModel address = AddressModel.fromPlacemark(placemark, location);
    await _cache.saveCurrentLocation(address);
    return address;
  }
}
