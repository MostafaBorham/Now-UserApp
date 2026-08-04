import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_stores_filter_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_stores_view.dart';

class CategoriesStoreTabView extends ConsumerStatefulWidget {
  const CategoriesStoreTabView({super.key});

  @override
  ConsumerState<CategoriesStoreTabView> createState() =>
      _CategoriesStoreTabViewState();
}

class _CategoriesStoreTabViewState
    extends ConsumerState<CategoriesStoreTabView> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        AppSearchField(hintText: LangKeys.searchForAStoreKey.tr()),
        Text(
          LangKeys.filtersKey.tr(),
          style: AppTextStyles.style16SemiBold.copyWith(
            color: colors.onSecondary,
          ),
        ),
        Expanded(
          child: CustomButtonTabBar(
            filterWidget: AppFilterIcon(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => CategoryStoresFilterView(
                  onApply: (type, rating) {
                    print('apply = $type$rating');
                  },
                ),
              ),
            ),
            tabs: StoresSortType.values
                .map((sortType) => sortType.label.tr())
                .toList(),
            views: StoresSortType.values.map((sortType) {
              return CategoryStoresView(sortType: sortType);
            }).toList(),
            selectedTabColor: colors.onTertiaryFixed,
            unSelectedTabColor: colors.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
