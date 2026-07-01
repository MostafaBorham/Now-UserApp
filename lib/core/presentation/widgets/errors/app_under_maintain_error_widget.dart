import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_postfix_icon_button.dart';

class AppUnderMaintainErrorWidget extends StatelessWidget {
  const AppUnderMaintainErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Assets.media.images.svg.appUnderMaintainIcon.svg(width: 300.w),
          10.hSpace,
          AutoSizeText(
            LangKeys.appUnderMaintenanceKey.tr(),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTextStyles.style24Bold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          AutoSizeText(
            LangKeys.appUnderMaintenanceSubtitleKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.style16Regular,
          ),
          15.hSpace,
          PrimaryAppPostfixIconButton(title: LangKeys.notifyMeWhenDoneKey.tr(),onTap: () {

          },postfixIcon: Assets.media.images.svg.alertErrorIcon.svg(colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn)),)
        ],
      ),
    );
  }
}
