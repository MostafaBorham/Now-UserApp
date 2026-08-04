import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_store_tab_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return AppWavedView(
      body: AppTabBar(
        tabs: [LangKeys.productsKey.tr(), LangKeys.storesKey.tr()],
        views: [FavouriteProductTabView(), FavouriteStoreTabView()],
        selectedTabColor: colors.primary500Main,
      ),
      appBarTitle: LangKeys.favouriteKey.tr(),
      canPop: context.canPop(),
    );
  }
}
