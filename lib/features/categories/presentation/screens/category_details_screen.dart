import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/categories_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/categories_store_tab_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';

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
        canPop: context.canPop(),
      ),
    );
  }
}
