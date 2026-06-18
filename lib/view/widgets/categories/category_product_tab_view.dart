import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/category_product_item.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/custom_button_tab_bar.dart';

class CategoryProductTabView extends StatelessWidget {
  const CategoryProductTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText('Filters',style: AppTextStyles.style14SemiBold.copyWith(
            color: colors.onSecondary
        ),),
        Expanded(child: CustomButtonTabBar(tabs: ['ALL','Men'], views: ['',''].map((e) => GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            mainAxisExtent: 250,
          ),
          itemCount: 6
          , itemBuilder: (BuildContext context, int index) => CategoryProductItem(),
        ),).toList(),selectedLabelColor: colors.onSecondary, selectedTabColor: colors.surfaceContainerHigh, unSelectedTabColor: colors.inversePrimary.withValues(alpha: 0.3),)),
      ],
    );
  }
}