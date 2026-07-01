import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/common/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_offers_item.dart';

import 'package:nowdelivery_user_app/common/presentation/styles/text_styles.dart';

class HomeOffersSection extends StatelessWidget {
  const HomeOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.media.images.png.homeOffersBackground.path,),
          fit: BoxFit.fitWidth
        ),
      ),
      child: Column(
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoSizeText(
                  LangKeys.dontMissTheseOffersKey.tr(),
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
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsetsDirectional.only(start: 15),
              itemBuilder: (context, index) {
                return HomeOffersItem();
              },
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return 10.wSpace;
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
