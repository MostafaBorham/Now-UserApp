import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_stores_list_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourites_tab_view.dart';






class FavouriteStoreTabView extends StatelessWidget {
  const FavouriteStoreTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return FavouritesTabView(
      type: 'vendor',
      listBuilder: (CategoryModel? category) =>
          FavouriteStoresListView(category: category),
    );
  }
}
