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
/// entered. [declined] — there is no cached location and the user refused to
/// switch the location service on (or no fix could be obtained), so the app
/// cannot be entered and the splash closes it.
enum CurrentLocationStatus { idle, resolving, ready, declined }

/// App-wide, always-alive orchestrator that guarantees a non-null current
/// location in the cache before the app is entered — the splash's location gate.
///
/// Deliberately **not** `autoDispose` and does not resolve on creation: the
/// splash calls [resolve] once its logo animation ends, then watches this state
/// to know whether it may leave ([ready]) or must close the app because the
/// user refused to switch the location service on ([declined]).
final currentLocationProvider =
    StateNotifierProvider<CurrentLocationViewModel, CurrentLocationStatus>(
  (Ref ref) => CurrentLocationViewModel(),
);

class CurrentLocationViewModel extends StateNotifier<CurrentLocationStatus> {
  CurrentLocationViewModel() : super(CurrentLocationStatus.idle);

  final CurrentLocationCacheService _cache = CurrentLocationCacheService();

  /// Runs the current-location scenario:
  ///
  /// * Read whatever is cached (may be null).
  /// * If the location service is off but something is cached, keep the cached
  ///   value — no prompt.
  /// * If the service is off and nothing is cached, ask the user to switch it on
  ///   through the native in-place system prompt. Refusing it leaves nothing to
  ///   enter the app with, so we settle on [declined] and the splash closes the
  ///   app.
  /// * Once the service is on (already, or just enabled), get a fresh device
  ///   fix, reverse-geocode it and overwrite the cache.
  /// * The cached current location may never stay null: a total miss with
  ///   nothing cached also settles on [declined].
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
      // Nothing cached: we must have a location, so ask to turn the service on
      // in place. Refusal is terminal — the app cannot be entered.
      serviceEnabled = await LocationManager.requestService();
      if (!mounted) return;
      if (!serviceEnabled) {
        state = CurrentLocationStatus.declined;
        return;
      }
    }

    // Service is on: refresh from a fresh device fix and cache it.
    final AddressModel? fresh = await _fetchAndCache();
    if (!mounted) return;
    state = (fresh != null || cached != null)
        ? CurrentLocationStatus.ready
        : CurrentLocationStatus.declined;
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
