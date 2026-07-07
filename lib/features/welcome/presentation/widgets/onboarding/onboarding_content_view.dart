import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/route/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/widgets/onboarding/or_divider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/app_logo.dart';

class OnBoardingContentView extends StatelessWidget {
  const OnBoardingContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    final Gradient screenGradient = LinearGradient(
      colors: [colors.secondaryFixed, colors.primary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0, 1],
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 40),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colors.inversePrimary.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 5,
        children: [
          AspectRatio(
              aspectRatio: 6.5,
              child: AppLogo(size: 200)),
          25.hSpace,
          AspectRatio(
            aspectRatio: 10,
            child: FittedBox(
              child: Text(
                LangKeys.onBoardingTitleKey.tr(),
                style: AppTextStyles.style24Bold.copyWith(
                  color: colors.onSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 10,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            LangKeys.thatSuitKey.tr(),
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
                                colors: [colors.secondary, colors.primary],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: const [0, 1],
                              ),
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
                            LangKeys.youKey.tr(),
                            style: AppTextStyles.style24SemiBold.copyWith(
                              height: 1,
                              color: colors.primary,
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
              ),
            ),
          ),
          8.hSpace,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              LangKeys.onBoardingSubTitleKey.tr(),
              style: AppTextStyles.style12Medium.copyWith(
                color: colors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          10.hSpace,
          AspectRatio(
            aspectRatio: 7.5,
            child: PrimaryGradientAppButton(
              title: LangKeys.loginKey.tr(),
              buttonGradient: screenGradient,
            ),
          ),
          10.hSpace,
          OrDivider(),
          10.hSpace,
          AspectRatio(
            aspectRatio: 7.5,
            child: UnPrimaryGradientAppButton(
              title: LangKeys.continueAsGuestKey.tr(),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.mainScreen,
                );
              },
              buttonGradient: screenGradient,
            ),
          ),
        ],
      ),
    );
  }
}
