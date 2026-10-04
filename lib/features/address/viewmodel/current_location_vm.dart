import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// Where the current-location bootstrap stands.
///
/// [idle] — nothing resolved yet (the VM was created but the splash has not
/// called [CurrentLocationViewModel.resolve]). [resolving] — a resolve pass is
/// in flight. [ready] — the pass is over and the app may be entered. A pass
/// always settles on [ready], with or without a location: when none can be
/// obtained (permission refused, service off, no fix) the cache is left as it
/// was, possibly empty, rather than blocking entry.
enum CurrentLocationStatus { idle, resolving, ready }

/// App-wide, always-alive orchestrator of the device's current location — the
/// splash's location gate, and the re-check run on resume and on a session
/// change.
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

  /// Runs the current-location scenario:
  ///
  /// * If the location service is on, get a fresh device fix, reverse-geocode
  ///   it and overwrite the cache.
  /// * If it is off and something is cached, keep the cached value.
  /// * If it is off and nothing is cached, ask the user to switch it on through
  ///   the native in-place system prompt — only when [prompt] is `true`. The
  ///   resume and session-change re-checks pass `false`: they must not pop a
  ///   system dialog over whatever the user is doing.
  ///
  /// There is no fallback location. With none obtained the cache stays empty
  /// and the home header asks the user to set one, instead of the app quietly
  /// searching around a made-up city.
  ///
  /// A pass always settles on [CurrentLocationStatus.ready], even when a plugin
  /// throws; entry is never blocked on the location. A call made while a pass
  /// is in flight is dropped, so two passes never prompt at once.
  Future<void> resolve({bool prompt = true}) async {
    if (state == CurrentLocationStatus.resolving) return;
    state = CurrentLocationStatus.resolving;
    try {
      bool serviceEnabled = await LocationManager.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!prompt || _cache.getCurrentLocation() != null) return;
        serviceEnabled = await LocationManager.requestService();
        if (!serviceEnabled || !mounted) return;
      }
      await _fetchAndCache();
    } catch (_) {
      // A plugin error is no location, not a stuck splash.
    } finally {
      if (mounted) state = CurrentLocationStatus.ready;
    }
  }

  /// Gets a fresh device fix, reverse-geocodes it into an [AddressModel] and
  /// caches it. Leaves the cache untouched when no fix or placemark could be
  /// resolved (permission denied, no coverage, etc.).
  Future<void> _fetchAndCache() async {
    final LatLng? location = await LocationManager.getCurrentLatLng();
    if (location == null) return;

    final Placemark? placemark = await LocationManager.getAddressFromLocation(
      location,
    );
    if (placemark == null) return;

    await _cache.saveCurrentLocation(
      AddressModel.fromPlacemark(placemark, location),
    );
  }
}
