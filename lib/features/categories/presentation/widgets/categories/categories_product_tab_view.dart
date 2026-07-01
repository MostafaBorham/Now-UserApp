import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/product_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';

class CategoriesProductTabView extends StatelessWidget {
  const CategoriesProductTabView({super.key});
  final bool isProductsEmpty = false;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        AppSearchField(hintText: LangKeys.searchForAProductKey.tr(),),
        Text(LangKeys.filtersKey.tr(),style: AppTextStyles.style14SemiBold.copyWith(
          color: colors.onSecondary
        ),),
        Expanded(
          child: isProductsEmpty? NoItemsWidget() : CustomButtonTabBar(
            tabs: [LangKeys.allKey.tr(), LangKeys.menKey.tr()],
            views: ['', '']
                .map(
                  (e) => GridView.builder(
                padding: EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemCount: 6,
                itemBuilder:
                    (BuildContext context, int index) =>
                ProductItem(),
              ),
            )
                .toList(),
            selectedLabelColor: colors.onSecondary,
            selectedTabColor: colors.secondary,
            unSelectedTabColor: colors.inversePrimary.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}