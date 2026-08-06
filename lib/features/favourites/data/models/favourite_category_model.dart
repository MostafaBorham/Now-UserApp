import 'package:equatable/equatable.dart';

/// A single category chip on the favourites screen, from
/// `GET /api/v1/favorites/categories`.
class FavouriteCategoryModel extends Equatable {
  final int id;

  /// Localized name as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(name)`.
  final Map<String, dynamic>? name;

  /// How many of the caller's favourites fall under this (top-level) category.
  final int favoritablesCount;

  const FavouriteCategoryModel({
    required this.id,
    this.name,
    this.favoritablesCount = 0,
  });

  factory FavouriteCategoryModel.fromJson(Map<String, dynamic> json) {
    return FavouriteCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as Map<String, dynamic>?,
      favoritablesCount: (json['favoritables_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, favoritablesCount];
}
