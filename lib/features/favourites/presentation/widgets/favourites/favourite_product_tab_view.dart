import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_products_list_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourites_tab_view.dart';

/// The caller's favourited products: a search field over an app-category tab
/// bar, each tab an infinite-scrolling grid of [FavouriteProductsListView].
///
/// Kept alive across the outer Products/Stores tab switch by the enclosing
/// [AppTabBar]; the filter selection lives in a provider, so it survives too.
class FavouriteProductTabView extends StatelessWidget {
  const FavouriteProductTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return FavouritesTabView(
      type: 'product',
      listBuilder: (int? categoryId) =>
          FavouriteProductsListView(categoryId: categoryId),
    );
  }
}
