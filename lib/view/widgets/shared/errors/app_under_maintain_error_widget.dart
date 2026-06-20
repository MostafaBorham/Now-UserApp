import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_postfix_icon_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_prefix_icon_button.dart';

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
            'App is under maintenance',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTextStyles.style24Bold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          AutoSizeText(
            'We’re working to improve your experience. We’ll be back soon. Thank you for your patience.',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.style16Regular,
          ),
          15.hSpace,
          PrimaryAppPostfixIconButton(title: 'Notify me when it’s done',onTap: () {

          },postfixIcon: Assets.media.images.svg.alertErrorIcon.svg(colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn)),)
        ],
      ),
    );
  }
}
