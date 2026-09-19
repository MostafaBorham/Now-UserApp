import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_stores_list_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourites_tab_view.dart';

/// The caller's favourited stores: a search field over an app-category tab bar,
/// each tab an infinite-scrolling list of [FavouriteStoresListView].
///
/// Kept alive across the outer Products/Stores tab switch by the enclosing
/// [AppTabBar]; the filter selection lives in a provider, so it survives too.
class FavouriteStoreTabView extends StatelessWidget {
  const FavouriteStoreTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return FavouritesTabView(
      type: 'vendor',
      listBuilder: (int? categoryId) =>
          FavouriteStoresListView(categoryId: categoryId),
    );
  }
}
