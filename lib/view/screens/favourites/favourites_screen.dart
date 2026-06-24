import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/widgets/favourites/favourite_product_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/favourites/favourite_store_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/app_tab_bar.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AppWavedScaffold(
      body: AppTabBar(
        tabs: ['Products', 'Stores'],
        views: [FavouriteProductTabView(), FavouriteStoreTabView()],
        selectedTabColor: colors.primary,
      ),
      appBarTitle: 'Favourite',
      canPop: Navigator.canPop(context),
    );
  }
}
