import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/product_item.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/text_fields/app_search_field.dart';

class FavouriteProductTabView extends StatelessWidget {
  const FavouriteProductTabView({super.key});
  final bool isProductsEmpty = false;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 16,
      children: [
        AppSearchField(hintText: LangKeys.searchForAProductKey.tr(),),
        Expanded(
          child: isProductsEmpty? NoItemsWidget() : CustomButtonTabBar(
            filterWidget: CircleAvatar(
              backgroundColor: colors.tertiary.withValues(alpha: 0.3),
              radius: 20.r,
              child: Assets.media.images.svg.filterIcon.svg(width: 20.w),
            ),
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
            selectedLabelColor: colors.onPrimary,
            selectedTabColor: colors.tertiaryContainer,
            unSelectedTabColor: colors.primaryFixed,
          ),
        ),
      ],
    );
  }
}
