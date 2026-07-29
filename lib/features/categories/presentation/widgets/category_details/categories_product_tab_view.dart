import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
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
  int? filterCategoryId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        AppSearchField(
          hintText: LangKeys.searchForAProductKey.tr(),
          hasFilter: true,
          onFilterTap: () => showModalBottomSheet(
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
        Expanded(child: CategoryProductsView()),
      ],
    );
  }
}
