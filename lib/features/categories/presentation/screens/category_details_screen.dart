import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/categories_product_tab_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/categories_store_tab_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

import '../providers/category_details/category_model_provider.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  const CategoryDetailsScreen({super.key, required this.category});

  /// Only the `slug` is guaranteed: a banner or an offer that links a category
  /// knows nothing else, so [_title] fills in a missing name.
  final CategoryModel category;

  /// The name the category was opened with, else the app-wide categories
  /// list's entry for this slug, else the generic title — never blank.
  String _title(BuildContext context, WidgetRef ref) {
    final Map<String, dynamic>? name =
        category.name ??
        ref.watch(
          getAppCategoriesProvider.select(
            (state) => state.valueOrNull?.data
                .where((CategoryModel known) => known.slug == category.slug)
                .firstOrNull
                ?.name,
          ),
        );
    final String title = context.getLocalizedApiText(name);
    return title.isEmpty ? LangKeys.categoriesTitleKey.tr() : title;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    return ProviderScope(
      overrides: [categoryProvider.overrideWithValue(category)],
      child: Scaffold(
        body: AppWavedView(
          bodyPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 40).copyWith(bottom: 0),
          body: AppTabBar(
            tabs: [LangKeys.productsKey.tr(), LangKeys.storesKey.tr()],
            views: [CategoriesProductTabView(), CategoriesStoreTabView()],
            selectedTabColor: colors.primary500Main,
          ),
          appBarTitle: _title(context, ref),
          canPop: context.canPop(),
        ),
      ),
    );
  }
}
