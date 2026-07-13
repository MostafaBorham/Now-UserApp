import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_stores_view.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_store_sub_categories_vm.dart';

import 'categories_store_shimmer_view.dart';

class CategoriesStoreTabView extends ConsumerStatefulWidget {
  const CategoriesStoreTabView({super.key});

  @override
  ConsumerState<CategoriesStoreTabView> createState() => _CategoriesStoreTabViewState();
}

class _CategoriesStoreTabViewState extends ConsumerState<CategoriesStoreTabView> {
  final bool isStoresEmpty = false;
  late final GetStoreSubCategoriesViewModel _subCategoriesViewModel;
  int? filterCategoryId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _subCategoriesViewModel = ref.read(getStoreSubCategoriesProvider.notifier);
/*    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchFilteredStores();
    });*/
  }

  void _fetchFilteredStores() {
/*    // print('=== $filterCategoryId');
    final categoryStoresViewModel = ref.read(
      filterCategoryStoresProvider(filterCategoryId).notifier,
    );
    categoryStoresViewModel.getCategoryStores(categorySlug: 'electronics');*/
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final storeSubCategories = ref.watch(getStoreSubCategoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        AppSearchField(hintText: LangKeys.searchForAStoreKey.tr(),reverseSearchIcon: context.isRTL,),
        Text(LangKeys.filtersKey.tr(),style: AppTextStyles.style16SemiBold.copyWith(
          color: colors.onSecondary
        ),),
        Expanded(
          child: storeSubCategories.when(
            loading: () => CategoriesStoreShimmerView(),
            error: (Object error, StackTrace stackTrace) =>
                ServerConnectionErrorWidget(
                  message: error.toString(),
                  onRetry: ()=> _subCategoriesViewModel.getStoreSubCategories(),
                ),
            data: (filterCategories) {
              final filterItems = [
                CategoryModel(
                  name: LangKeys.allKey.tr(),
                  slug: LangKeys.allKey.tr(),
                ),
                ...filterCategories,
              ];
              return CustomButtonTabBar(
                filterWidget: AppFilterIcon(),
                onTap: (index) {
/*                  print('current = $index');
                  filterCategoryId = filterItems.elementAt(index).id;
                  _fetchFilteredStores();*/
                },
                tabs: filterItems.map((filter) => '${filter.name}').toList(),
                views: filterItems.map((category) {
                  return CategoryStoresView(
                    subCategory: category,
                  );
                }).toList(),
                selectedTabColor: colors.onTertiaryFixed,
                unSelectedTabColor: colors.onSurface.withValues(alpha: 0.2),
              );
            },
          ),
        ),
      ],
    );
  }
}