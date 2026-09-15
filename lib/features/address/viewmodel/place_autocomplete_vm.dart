import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/place_suggestion_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/places_repo.dart';






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




  static const Duration _debounceDelay = Duration(milliseconds: 300);

  final PlacesRepo _repo = PlacesRepo();

  Timer? _debounceTimer;




  int _sequence = 0;

  String _sessionToken = _newSessionToken();





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





  Future<Either<Failure, LatLng>> resolveLocation({
    required String placeId,
    required String languageCode,
  }) async {
    final Either<Failure, LatLng> result = await _repo.getPlaceLocation(
      placeId: placeId,
      languageCode: languageCode,
      sessionToken: _sessionToken,
    );



    _sessionToken = _newSessionToken();

    return result;
  }




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
