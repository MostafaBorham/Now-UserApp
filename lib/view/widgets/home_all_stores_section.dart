import 'package:auto_size_text/auto_size_text.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/widgets/home_store_list_item.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/custom_button_tab_bar.dart';

import '../../common/localization/lang_keys.dart';
import '../styles/text_styles.dart';

class HomeAllStoresSection extends StatelessWidget {
  const HomeAllStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                'Don\'t Miss These Offers',
                style: AppTextStyles.style20SemiBold.copyWith(
                  color: colors.onSecondary,
                ),
              ),
              InkWell(
                onTap: () {},
                child: AutoSizeText(
                  LangKeys.showMoreKey.tr(),
                  style: AppTextStyles.style12SemiBold.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: CustomButtonTabBar(
              filterWidget: CircleAvatar(
                backgroundColor: colors.tertiary.withValues(alpha: 0.3),
                radius: 20.r,
                child: Assets.media.images.svg.filterIcon.svg(
                  width: 20.w
                ),
              ),
              tabs: ['ALL','Clothes','Other'],
              views: [
                LayoutBuilder(
                  builder: (context,con) {
                    return ListView.separated(
                      itemBuilder: (context, index) => SizedBox(
                          height: con.maxHeight*0.6,
                          child: HomeStoreListItem()),
                      separatorBuilder: (context, index) => 20.hSpace,
                      itemCount: 3,
                    );
                  }
                ),
                LayoutBuilder(
                  builder: (context,con) {
                    return ListView.separated(
                      itemBuilder: (context, index) => SizedBox(
                          height: con.maxHeight*0.6,
                          child: HomeStoreListItem()),
                      separatorBuilder: (context, index) => 20.hSpace,
                      itemCount: 3,
                    );
                  }
                ),
                LayoutBuilder(
                  builder: (context,con) {
                    return ListView.separated(
                      itemBuilder: (context, index) => SizedBox(
                          height: con.maxHeight*0.6,
                          child: HomeStoreListItem()),
                      separatorBuilder: (context, index) => 20.hSpace,
                      itemCount: 3,
                    );
                  }
                ),
              ],
              selectedTabColor: colors.tertiaryContainer,
              unSelectedTabColor: colors.primaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}
