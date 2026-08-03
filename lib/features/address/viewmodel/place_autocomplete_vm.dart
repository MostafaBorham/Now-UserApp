import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/place_suggestion_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/places_repo.dart';

/// Drives the result list of the address search screen.
///
/// Starts out as empty `data` rather than `loading`, because nothing is
/// searched until the user types: the screen only renders this provider while
/// the field holds text.
final placeAutocompleteProvider =
    StateNotifierProvider.autoDispose<
      PlaceAutocompleteViewModel,
      AsyncValue<List<PlaceSuggestionModel>>
    >(
      (Ref ref) => PlaceAutocompleteViewModel(
        const AsyncValue<List<PlaceSuggestionModel>>.data(
          <PlaceSuggestionModel>[],
        ),
      ),
    );

class PlaceAutocompleteViewModel
    extends StateNotifier<AsyncValue<List<PlaceSuggestionModel>>> {
  PlaceAutocompleteViewModel(super.initialState);

  /// Idle time after the last keystroke before a request goes out — long
  /// enough that a normally typed word costs one call, short enough to feel
  /// instant.
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  final PlacesRepo _repo = PlacesRepo();

  Timer? _debounceTimer;

  /// Incremented on every [search]. A response is applied only while its
  /// sequence is still the latest, so a slow reply for an old query can never
  /// overwrite the results of a newer one.
  int _sequence = 0;

  String _sessionToken = _newSessionToken();

  /// Debounced autocomplete for [query].
  ///
  /// A blank query resets straight to an empty list — no request, no spinner —
  /// which is what the screen shows while the recents are on display.
  void search({
    required String query,
    required String languageCode,
    LatLng? locationBias,
  }) {
    _debounceTimer?.cancel();

    final String term = query.trim();
    final int sequence = ++_sequence;

    if (term.isEmpty) {
      state = const AsyncValue<List<PlaceSuggestionModel>>.data(
        <PlaceSuggestionModel>[],
      );
      return;
    }

    // Show the spinner immediately, while the debounce is still counting down,
    // so typing never looks like it did nothing.
    state = const AsyncValue<List<PlaceSuggestionModel>>.loading();

    _debounceTimer = Timer(
      _debounceDelay,
      () => _fetchSuggestions(
        term: term,
        languageCode: languageCode,
        locationBias: locationBias,
        sequence: sequence,
      ),
    );
  }

  Future<void> _fetchSuggestions({
    required String term,
    required String languageCode,
    required LatLng? locationBias,
    required int sequence,
  }) async {
    final Either<Failure, List<PlaceSuggestionModel>> result =
        await _repo.autocomplete(
          input: term,
          languageCode: languageCode,
          sessionToken: _sessionToken,
          locationBias: locationBias,
        );

    if (!mounted || sequence != _sequence) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<PlaceSuggestionModel> suggestions) =>
          AsyncValue.data(suggestions),
    );
  }

  /// Resolves the coordinates of the picked [placeId] and closes the billing
  /// session. The result is returned to the caller instead of being pushed
  /// into [state]: the screen navigates on success and shows a snackbar on
  /// failure, and the list itself must not change either way.
  Future<Either<Failure, LatLng>> resolveLocation({
    required String placeId,
    required String languageCode,
  }) async {
    final Either<Failure, LatLng> result = await _repo.getPlaceLocation(
      placeId: placeId,
      languageCode: languageCode,
      sessionToken: _sessionToken,
    );

    // A session ends with its details call; anything typed next starts a new
    // one. Rotating even after a failure keeps a broken token from sticking.
    _sessionToken = _newSessionToken();

    return result;
  }

  /// Google bills autocomplete per *session*: every keystroke plus the closing
  /// Place Details call share one token and are charged once, instead of once
  /// per request. The API expects a UUID-shaped opaque string.
  static String _newSessionToken() {
    final Random random = Random.secure();
    String block(int bytes) => List<String>.generate(
      bytes,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();

    return '${block(4)}-${block(2)}-${block(2)}-${block(2)}-${block(6)}';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _repo.cancelRequests();
    super.dispose();
  }
}
