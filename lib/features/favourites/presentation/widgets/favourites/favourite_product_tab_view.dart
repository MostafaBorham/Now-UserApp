import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_products_list_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourites_tab_view.dart';






class FavouriteProductTabView extends StatelessWidget {
  const FavouriteProductTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return FavouritesTabView(
      type: 'product',
      listBuilder: (CategoryModel? category) =>
          FavouriteProductsListView(category: category),
    );
  }
}
