import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_store_tab_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key, this.canPop});

  /// Whether the app bar shows a back arrow.
  ///
  /// Left `null` the view falls back to `context.canPop()`, which is right for
  /// the pushed route. The copy embedded in the main screen's tab bar must pass
  /// `false`: it shares the root navigator, so once another screen is pushed
  /// `context.canPop()` turns `true` for it too and any rebuild while that
  /// screen is open leaves a back arrow behind after popping back.
  final bool? canPop;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedView(
        body: AppTabBar(
          tabs: [LangKeys.productsKey.tr(), LangKeys.storesKey.tr()],
          views: const [FavouriteProductTabView(), FavouriteStoreTabView()],
          selectedTabColor: colors.primary,
        ),
        appBarTitle: LangKeys.favouriteKey.tr(),
        canPop: canPop,
      ),
    );
  }
}
