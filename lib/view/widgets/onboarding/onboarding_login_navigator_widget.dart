import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/route/app_routes.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/onboarding/or_divider.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/unprimary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/logos/app_logo.dart';

class OnBoardingLoginNavigatorWidget extends StatelessWidget {
  const OnBoardingLoginNavigatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    final Gradient screenGradient = LinearGradient(
      colors: [
        colors.secondaryFixed,
        colors.primary,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0, 1],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0,vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colors.inversePrimary.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            AppLogo(size: 150.sp),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'That suit',
                        style: AppTextStyles.style24SemiBold.copyWith(
                          height: 1,
                          foreground: Paint()
                            ..shader = screenGradient.createShader(
                              const Rect.fromLTWH(0, 0, 300, 70),
                            ),
                        ),
                      ),
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.secondary,
                              colors.primary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0, 1],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'you',
                        style: AppTextStyles.style24SemiBold.copyWith(
                          height: 1,
                          color: colors.primary
                        ),
                      ),
                      Container(
                        margin: EdgeInsetsDirectional.only(start: 15),
                        height: 5,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              LangKeys.onBoardingSubTitleKey.tr(),
              style: AppTextStyles.style12Medium.copyWith(
                color: colors.onSurface
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            10.hSpace,
            PrimaryGradientAppButton(title: LangKeys.loginKey.tr(), buttonGradient: screenGradient,),
            3.hSpace,
            OrDivider(),
            3.hSpace,
            UnPrimaryGradientAppButton(
              title: LangKeys.loginAsGuestKey.tr(),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.mainLayoutScreen,
                );
              }, buttonGradient: screenGradient,
            ),
          ],
        ),
      ),
    );
  }
}
