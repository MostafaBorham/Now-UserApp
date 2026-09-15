import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';

import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class HomeAllStoresSection extends StatelessWidget {
  const HomeAllStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                'All Stores',
                style: AppTextStyles.style20SemiBold.copyWith(
                  color: colors.black,
                ),
              ),
              InkWell(
                onTap: () {
                  context.pushNamed(AppRoutes.allStoresScreen);
                },
                child: AutoSizeText(
                  LangKeys.seeAllKey.tr(),
                  style: AppTextStyles.style12SemiBold.copyWith(
                    color: colors.primary500Main,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: CustomButtonTabBar(
              filterWidget: AppFilterIcon(),
              tabs: [LangKeys.allKey.tr(), LangKeys.clothesKey.tr(), LangKeys.otherKey.tr()],
              views: List.generate(3, (index) => LayoutBuilder(
                builder: (context, con) {
                  return ListView.separated(
                    itemBuilder: (context, index) => SizedBox(
                      height: con.maxHeight * 0.6,
                      child: InkWell(
                          onTap: () => context.pushNamed(AppRoutes.storeDetailsScreen),
                          child: StoreItem()),
                    ),
                    separatorBuilder: (context, index) => 20.hSpace,
                    itemCount: 3,
                  );
                },
              ),),

              unSelectedTabColor: colors.primaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}
