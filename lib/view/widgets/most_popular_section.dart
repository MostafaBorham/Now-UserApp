import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular_item.dart';

import '../styles/text_styles.dart';

class MostPopularSection extends StatelessWidget {
  const MostPopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.tertiary, colors.onPrimary],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
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
                  LangKeys.mostPopularKey.tr(),
                  style: AppTextStyles.style20SemiBold.copyWith(
                    color: colors.onSecondary,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: AutoSizeText(
                    LangKeys.showMoreKey.tr(),
                    style: AppTextStyles.style12SemiBold.copyWith(
                      color: colors.onSecondary,
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
                return MostPopularItem();
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
