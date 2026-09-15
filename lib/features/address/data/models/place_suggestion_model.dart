import 'package:equatable/equatable.dart';

class PlaceSuggestionModel extends Equatable {
  final String placeId;

  final String mainText;

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
      mainText: main?['text']?.toString() ?? text?['text']?.toString() ?? '',
      secondaryText: secondary?['text']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => <Object?>[placeId, mainText, secondaryText];
}
