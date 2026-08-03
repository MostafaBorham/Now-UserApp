import 'package:equatable/equatable.dart';

/// A single row of the address search results — one prediction returned by
/// Google Places Autocomplete (New).
///
/// Built from a `suggestions[].placePrediction` object; the sibling
/// `queryPrediction` entries carry no place id and are dropped by the repo.
class PlaceSuggestionModel extends Equatable {
  /// Google place id, used to fetch the coordinates from Place Details.
  final String placeId;

  /// Highlighted part of the prediction (e.g. `Cairo`) — the tile title.
  final String mainText;

  /// Remainder of the prediction (e.g. `Cairo Governorate, Egypt`) — the tile
  /// subtitle. Empty when Google returns no structured format.
  final String secondaryText;

  const PlaceSuggestionModel({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PlaceSuggestionModel(
        placeId: '',
        mainText: '',
        secondaryText: '',
      );
    }

    final Map<String, dynamic>? structured =
        json['structuredFormat'] as Map<String, dynamic>?;
    final Map<String, dynamic>? main =
        structured?['mainText'] as Map<String, dynamic>?;
    final Map<String, dynamic>? secondary =
        structured?['secondaryText'] as Map<String, dynamic>?;
    final Map<String, dynamic>? text = json['text'] as Map<String, dynamic>?;

    return PlaceSuggestionModel(
      placeId: json['placeId']?.toString() ?? '',
      // `structuredFormat` is optional — fall back to the flat `text` field so
      // the tile is never blank.
      mainText: main?['text']?.toString() ?? text?['text']?.toString() ?? '',
      secondaryText: secondary?['text']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => <Object?>[placeId, mainText, secondaryText];
}
