import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/models/category_model.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/view/widgets/favourites/favourite_product_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/favourites/favourite_store_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/errors/app_under_maintain_error_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/app_tab_bar.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/reverse_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/custom_tab_bar_with_fixed_widget.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AppWavedScaffold(body: AppTabBar(
      tabs: ['Products', 'Stores'],
      views: [
        FavouriteProductTabView(),
        FavouriteStoreTabView(),
      ],
      selectedTabColor: colors.primary,
    ), appBarTitle: 'Favourite',);
  }
}