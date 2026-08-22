import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';

/// The combined search / filter selection that drives the All Stores screen:
/// the [search] text, the selected [category] (`null` = the "All" tab), and the
/// [rating] filter. Kept as one object so a store list reacts to a single change.
@immutable
class StoresSearchFilter {
  const StoresSearchFilter({
    this.search = '',
    this.category,
    this.rating = '',
  });

  /// The store search text. Empty means no search.
  final String search;

  /// The selected category, or `null` for the "All" tab.
  final CategoryModel? category;

  /// The rating filter (e.g. `'4.5'`). Empty means no rating filter.
  final String rating;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoresSearchFilter &&
          other.search == search &&
          other.category == category &&
          other.rating == rating;

  @override
  int get hashCode => Object.hash(search, category, rating);
}

/// Holds the [StoresSearchFilter] for the All Stores screen. The screen mutates
/// it in exactly three cases — a category tab change, returning from the filter
/// sheet, and using the search field — through the three methods below.
class StoresSearchFilterNotifier extends StateNotifier<StoresSearchFilter> {
  StoresSearchFilterNotifier() : super(const StoresSearchFilter());

  /// The search field changed. Keeps the current category and rating.
  void setSearch(String search) => state = StoresSearchFilter(
        search: search,
        category: state.category,
        rating: state.rating,
      );

  /// A category tab was selected (`null` = the "All" tab). Keeps search/rating.
  void setCategory(CategoryModel? category) => state = StoresSearchFilter(
        search: state.search,
        category: category,
        rating: state.rating,
      );

  /// Returned from the filter sheet with a picked [category] and [rating]. Keeps
  /// the current search text.
  void applyFilter({CategoryModel? category, String rating = ''}) =>
      state = StoresSearchFilter(
        search: state.search,
        category: category,
        rating: rating,
      );
}

/// The All Stores screen's search/filter state. Auto-disposes (resets) when the
/// screen is left.
final storesSearchFilterProvider = StateNotifierProvider.autoDispose<
    StoresSearchFilterNotifier, StoresSearchFilter>(
  (ref) => StoresSearchFilterNotifier(),
);
