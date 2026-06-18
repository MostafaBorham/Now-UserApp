import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/category_product_item.dart';
import 'package:nowdelivery_user_app/view/widgets/categories/category_store_item.dart';
import 'package:nowdelivery_user_app/view/widgets/home/home_offers_item.dart';
import 'package:nowdelivery_user_app/view/widgets/home/home_store_list_item.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/custom_button_tab_bar.dart';

class FavouriteStoreTabView extends StatelessWidget {
  const FavouriteStoreTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return CustomButtonTabBar(
      filterWidget: CircleAvatar(
        backgroundColor: colors.tertiary.withValues(alpha: 0.3),
        radius: 20.r,
        child: Assets.media.images.svg.filterIcon.svg(width: 20.w),
      ),
      tabs: ['ALL', 'Men'],
      views: ['', '']
          .map(
            (e) => LayoutBuilder(
              builder: (context, con) {
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => SizedBox(
                    height: con.maxHeight * 0.43,
                    child: CategoryStoreItem(),
                  ),
                  separatorBuilder: (context, index) => 20.hSpace,
                  itemCount: 3,
                );
              },
            ),
      )
          .toList(),
      selectedLabelColor: colors.onPrimary,
      selectedTabColor: colors.tertiaryContainer,
      unSelectedTabColor: colors.primaryFixed,
    );
  }
}