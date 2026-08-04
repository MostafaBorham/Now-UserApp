import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/categories_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/categories_store_tab_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';

import '../providers/category_details/category_model_provider.dart';

class CategoryDetailsScreen extends StatelessWidget {
  const CategoryDetailsScreen({super.key, required this.category});
  final CategoryModel category;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return ProviderScope(
      overrides: [categoryProvider.overrideWithValue(category)],
      child: Scaffold(
        body: AppWavedView(
          body: AppTabBar(
            tabs: [LangKeys.productsKey.tr(), LangKeys.storesKey.tr()],
            views: [CategoriesProductTabView(), CategoriesStoreTabView()],
            selectedTabColor: colors.primary,
          ),
          appBarTitle: context.getLocalizedApiText(category.name),
          canPop: context.canPop(),
        ),
      ),
    );
  }
}
