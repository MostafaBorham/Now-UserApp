import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_filter_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view.dart';

class CategoriesProductTabView extends ConsumerStatefulWidget {
  const CategoriesProductTabView({super.key});

  @override
  ConsumerState<CategoriesProductTabView> createState() =>
      _CategoriesProductTabViewState();
}

class _CategoriesProductTabViewState
    extends ConsumerState<CategoriesProductTabView> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        PrimarySearchField(),
        Text(
          LangKeys.categoriesKey.tr(),
          style: AppTextStyles.style16SemiBold.copyWith(color: colors.black),
        ),
        Expanded(
          child: CustomButtonTabBar(
            filterWidget: AppFilterIcon(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => CategoryProductsFilterView(
                  onApply: (separateOption, maxPrice, minPrice, rating) {
                    print(
                      'apply = ${separateOption?.label}$maxPrice$minPrice$rating',
                    );
                  },
                ),
              ),
            ),
            tabs: StoresSortType.values
                .map((sortType) => sortType.label.tr())
                .toList(),
            views: StoresSortType.values.map((sortType) {
              return CategoryProductsView(sortType: sortType);
            }).toList(),
            unSelectedTabColor: colors.neutral500.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
