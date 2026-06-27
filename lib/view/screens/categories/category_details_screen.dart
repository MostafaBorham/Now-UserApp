import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/categories_product_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/categories_store_tab_view.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/app_tab_bar.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/custom_tab_bar_with_fixed_widget.dart';

class CategoryDetailsScreen extends StatelessWidget {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: AppTabBar(
          tabs: [LangKeys.productsKey.tr(), LangKeys.storesKey.tr()],
          views: [CategoriesProductTabView(), CategoriesStoreTabView()],
          selectedTabColor: colors.primary,
        ),
        appBarTitle: LangKeys.offersKey.tr(),
        canPop: Navigator.canPop(context),
      ),
    );
  }
}
