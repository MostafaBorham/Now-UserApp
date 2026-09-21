import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The combined search / filter selection that drives the All Stores screen:
/// the [search] text, the selected [categoryId] (`null` = the "All" tab), and
/// the [rating] filter. Kept as one object so a store list reacts to a single
/// change.
///
/// The category is held as an **id**, not as a `CategoryModel`. The model is
/// `Equatable` over all of its fields, so re-fetching the categories list with
/// any unrelated field changed (`products_count`, `updated_at`, …) used to make
/// the stored selection equal to nothing at all: the tab bar fell back to "All"
/// while the filter still named the old category, and every tab — "All"
/// included — then failed its own selection check and sat on the shimmer
/// forever. An id is the part that actually identifies the tab.
@immutable
class StoresSearchFilter {
  const StoresSearchFilter({
    this.search = '',
    this.categoryId,
    this.rating = '',
  });

  /// The store search text. Empty means no search.
  final String search;

  /// The selected category's id, or `null` for the "All" tab.
  final int? categoryId;

  /// The rating filter (e.g. `'4.5'`). Empty means no rating filter.
  final String rating;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoresSearchFilter &&
          other.search == search &&
          other.categoryId == categoryId &&
          other.rating == rating;

  @override
  int get hashCode => Object.hash(search, categoryId, rating);
}

/// Holds the [StoresSearchFilter] for the All Stores screen. The screen mutates
/// it in exactly three cases — a category tab change, returning from the filter
/// sheet, and using the search field — through the three methods below.
class StoresSearchFilterNotifier extends StateNotifier<StoresSearchFilter> {
  StoresSearchFilterNotifier() : super(const StoresSearchFilter());

  /// The search field changed. Keeps the current category and rating.
  void setSearch(String search) => state = StoresSearchFilter(
    search: search,
    categoryId: state.categoryId,
    rating: state.rating,
  );

  /// A category tab was selected (`null` = the "All" tab). Keeps search/rating.
  void setCategory(int? categoryId) => state = StoresSearchFilter(
    search: state.search,
    categoryId: categoryId,
    rating: state.rating,
  );

  /// Returned from the filter sheet with a picked [categoryId] and [rating].
  /// Keeps the current search text.
  void applyFilter({int? categoryId, String rating = ''}) =>
      state = StoresSearchFilter(
        search: state.search,
        categoryId: categoryId,
        rating: rating,
      );
}

/// The All Stores screen's search/filter state. Auto-disposes (resets) when the
/// screen is left.
final storesSearchFilterProvider =
    StateNotifierProvider.autoDispose<
      StoresSearchFilterNotifier,
      StoresSearchFilter
    >((ref) => StoresSearchFilterNotifier());
