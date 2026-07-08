import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/all_stores/stores_list_view.dart';

class CategoriesStoreTabView extends StatelessWidget {
  const CategoriesStoreTabView({super.key});

  final bool isStoresEmpty = false;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        AppSearchField(hintText: LangKeys.searchForAStoreKey.tr()),
        Text('Filters',style: AppTextStyles.style16SemiBold.copyWith(
          color: colors.onSecondary
        ),),
        Expanded(
          child: CustomButtonTabBar(
            filterWidget: AppFilterIcon(),
            tabs: [LangKeys.allKey.tr(),...['Devices','Shoes','Cloths']],
            views: List.generate(4, (index) => ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => AspectRatio(
                  aspectRatio: 2,
                  child: StoreItem()),
              separatorBuilder: (context, index) => 20.hSpace,
              itemCount: 3,
            ),),
            selectedTabColor: colors.onTertiaryFixed,
            unSelectedTabColor: colors.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}