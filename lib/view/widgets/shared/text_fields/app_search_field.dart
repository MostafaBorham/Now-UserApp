import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/app_borders.dart';
import 'package:nowdelivery_user_app/view/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, this.hintText});
  final String? hintText;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: AppBorderRadius.brCircular30,
        boxShadow: AppBoxShadows.blackBottomShadow1,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText?? LangKeys.searchNowKey.tr(),
          hintStyle: AppTextStyles.style16Regular.copyWith(
            color:colors.onPrimaryFixed
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Assets.media.images.svg.searchIcon.svg(
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 25.w,
            minWidth: 25.w,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8
          ),
        ),
      ),
    );
  }
}
