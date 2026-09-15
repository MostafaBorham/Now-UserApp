import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';

@immutable
class StoresSearchFilter {
  const StoresSearchFilter({
    this.search = '',
    this.category,
    this.rating = '',
  });

  final String search;

  final CategoryModel? category;

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

class StoresSearchFilterNotifier extends StateNotifier<StoresSearchFilter> {
  StoresSearchFilterNotifier() : super(const StoresSearchFilter());

  void setSearch(String search) => state = StoresSearchFilter(
        search: search,
        category: state.category,
        rating: state.rating,
      );

  void setCategory(CategoryModel? category) => state = StoresSearchFilter(
        search: state.search,
        category: category,
        rating: state.rating,
      );

  void applyFilter({CategoryModel? category, String rating = ''}) =>
      state = StoresSearchFilter(
        search: state.search,
        category: category,
        rating: rating,
      );
}

final storesSearchFilterProvider = StateNotifierProvider.autoDispose<
    StoresSearchFilterNotifier, StoresSearchFilter>(
  (ref) => StoresSearchFilterNotifier(),
);
