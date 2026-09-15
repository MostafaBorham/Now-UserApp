import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';




@immutable
class FavouritesFilter {
  const FavouritesFilter({this.search = '', this.category});


  final String search;


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




class FavouritesFilterNotifier extends StateNotifier<FavouritesFilter> {
  FavouritesFilterNotifier() : super(const FavouritesFilter());


  void setSearch(String search) =>
      state = FavouritesFilter(search: search, category: state.category);


  void setCategory(CategoryModel? category) =>
      state = FavouritesFilter(search: state.search, category: category);
}





final favouritesFilterProvider = StateNotifierProvider.autoDispose
    .family<FavouritesFilterNotifier, FavouritesFilter, String>(
  (Ref ref, String type) => FavouritesFilterNotifier(),
);
