import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// Where the guaranteed-current-location bootstrap stands.
///
/// [idle] — nothing resolved yet (the VM was created but the splash has not
/// called [CurrentLocationViewModel.resolve]). [resolving] — a resolve pass is
/// in flight. [ready] — a non-null current location is cached; the app may be
/// entered. A resolve pass always settles on [ready]: when there is no cached
/// location and none can be obtained (permission refused, service off, no fix),
/// it falls back to [CurrentLocationViewModel.defaultLocation] rather than
/// blocking entry.
enum CurrentLocationStatus { idle, resolving, ready }

/// App-wide, always-alive orchestrator that guarantees a non-null current
/// location in the cache before the app is entered — the splash's location gate.
///
/// Deliberately **not** `autoDispose` and does not resolve on creation: the
/// splash calls [resolve] once its logo animation ends, then watches this state
/// for [ready] to know it may leave.
final currentLocationProvider =
    StateNotifierProvider<CurrentLocationViewModel, CurrentLocationStatus>(
  (Ref ref) => CurrentLocationViewModel(),
);

class CurrentLocationViewModel extends StateNotifier<CurrentLocationStatus> {
  CurrentLocationViewModel() : super(CurrentLocationStatus.idle);

  final CurrentLocationCacheService _cache = CurrentLocationCacheService();

  /// The Riyadh coordinates the bootstrap falls back to when no real location
  /// can be obtained, so the cached current location is never null.
  static const LatLng defaultLocation = LatLng(24.7136, 46.6753);

  /// Runs the current-location scenario:
  ///
  /// * Read whatever is cached (may be null).
  /// * If the location service is off but something is cached, keep the cached
  ///   value — no prompt.
  /// * If the service is off and nothing is cached, ask the user to switch it on
  ///   through the native in-place system prompt.
  /// * Once the service is on (already, or just enabled), get a fresh device
  ///   fix, reverse-geocode it and overwrite the cache.
  /// * When no real location can be obtained and nothing is cached (permission
  ///   refused, service left off, no fix), fall back to [defaultLocation] so the
  ///   cache is never null.
  ///
  /// A resolve pass always settles on [CurrentLocationStatus.ready]; entry is
  /// never blocked on the location.
  Future<void> resolve() async {
    state = CurrentLocationStatus.resolving;

    final AddressModel? cached = _cache.getCurrentLocation();
    bool serviceEnabled = await LocationManager.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // A cached location lets us in without disturbing the user.
      if (cached != null) {
        state = CurrentLocationStatus.ready;
        return;
      }
      // Nothing cached: ask to turn the service on in place. A refusal falls
      // back to the default location below rather than blocking entry.
      serviceEnabled = await LocationManager.requestService();
      if (!mounted) return;
    }

    if (serviceEnabled) {
      // Service is on: refresh from a fresh device fix and cache it.
      final AddressModel? fresh = await _fetchAndCache();
      if (!mounted) return;
      if (fresh != null || cached != null) {
        state = CurrentLocationStatus.ready;
        return;
      }
    }

    // No cached location and none could be obtained: fall back to the default.
    await _cacheDefaultLocation();
    if (!mounted) return;
    state = CurrentLocationStatus.ready;
  }

  /// Reverse-geocodes [defaultLocation] into an [AddressModel] and caches it as
  /// the current location. On a geocoding miss (no connectivity/coverage) a
  /// minimal Riyadh model carrying just the coordinates is cached instead, so
  /// the current location is always non-null.
  Future<void> _cacheDefaultLocation() async {
    final Placemark? placemark =
        await LocationManager.getAddressFromLocation(defaultLocation);
    final AddressModel address = placemark != null
        ? AddressModel.fromPlacemark(placemark, defaultLocation)
        : const AddressModel(
            country: 'Saudi Arabia',
            city: 'Riyadh',
            area: 'Riyadh',
            latitude: '24.7136',
            longitude: '46.6753',
          );
    await _cache.saveCurrentLocation(address);
  }

  /// Gets a fresh device fix, reverse-geocodes it into an [AddressModel] and
  /// caches it. Returns the cached address on success, or `null` when no fix or
  /// placemark could be resolved (permission denied, no coverage, etc.).
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
