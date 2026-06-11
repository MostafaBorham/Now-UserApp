import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/route/app_routes.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/widgets/app_logo.dart';

import '../widgets/or_divider.dart';
import '../widgets/primary_app_button.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Assets.media.images.svg.onboardingBackground.svg(
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: SafeArea(
              child: Assets.media.images.png.onboardingImg.image(
                fit: BoxFit.contain,
                height: 400.w,
                width: 400.w,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 33, horizontal: 24),
              width: double.infinity,
              height: 450.h,
              decoration: BoxDecoration(
                color: colors.onPrimary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: colors.inversePrimary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  AppLogo(size: 200.sp),
                  20.hSpace,
                  AutoSizeText(
                    LangKeys.onBoardingTitleKey.tr(),
                    style: textThemes.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSecondary,
                    ),
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  AutoSizeText(
                    LangKeys.onBoardingSubTitleKey.tr(),
                    style: textThemes.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    minFontSize: 7,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  10.hSpace,
                  PrimaryAppButton(
                    title: LangKeys.loginKey.tr(),
                    isFilled: true,
                  ),
                  7.hSpace,
                  OrDivider(),
                  7.hSpace,
                  PrimaryAppButton(
                    title: LangKeys.loginAsGuestKey.tr(),
                    isFilled: false,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.homeScreen,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
