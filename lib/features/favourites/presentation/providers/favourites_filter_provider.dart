import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';

/// The search / category selection driving one favourites tab: the [search]
/// text and the selected app [category] (`null` = the "All" tab). Kept as one
/// object so a favourites list reacts to a single change.
@immutable
class FavouritesFilter {
  const FavouritesFilter({this.search = '', this.category});

  /// The favourites search text. Empty means no search.
  final String search;

  /// The selected app category, or `null` for the "All" tab.
  final CategoryModel? category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouritesFilter &&
          other.search == search &&
          other.category == category;

  @override
  int get hashCode => Object.hash(search, category);
}

/// Holds the [FavouritesFilter] for one favourites tab. Mutated in exactly two
/// cases — using the search field and switching the category tab — through the
/// two methods below, each preserving the other selection.
class FavouritesFilterNotifier extends StateNotifier<FavouritesFilter> {
  FavouritesFilterNotifier() : super(const FavouritesFilter());

  /// The search field changed. Keeps the current category.
  void setSearch(String search) =>
      state = FavouritesFilter(search: search, category: state.category);

  /// A category tab was selected (`null` = the "All" tab). Keeps the search.
  void setCategory(CategoryModel? category) =>
      state = FavouritesFilter(search: state.search, category: category);
}

/// One filter per tab kind — keyed by the API discriminator (`product` /
/// `vendor`) — so the Products and Stores tabs keep independent search and
/// category selections. Auto-disposes (resets) once the favourites screen is
/// left.
final favouritesFilterProvider = StateNotifierProvider.autoDispose
    .family<FavouritesFilterNotifier, FavouritesFilter, String>(
  (Ref ref, String type) => FavouritesFilterNotifier(),
);
