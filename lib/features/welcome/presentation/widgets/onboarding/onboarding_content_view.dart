import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/welcome/viewmodel/guest_token_vm.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/widgets/onboarding/or_divider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/app_logo.dart';

class OnBoardingContentView extends ConsumerWidget {
  const OnBoardingContentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    ref.listen<AsyncValue<String?>>(generateGuestTokenProvider, (
      AsyncValue<String?>? previous,
      AsyncValue<String?> next,
    ) {
      next.whenOrNull(
        data: (String? guestToken) {
          if (guestToken != null) {
            context.goNamed(AppRoutes.mainScreen);
          }
        },
        error: (Object error, StackTrace stackTrace) =>
            ErrorSnackBar.show(context, error.toString()),
      );
    });
    final bool isGuestTokenLoading = ref
        .watch(generateGuestTokenProvider)
        .isLoading;

    final Gradient screenGradient = LinearGradient(
      colors: [colors.secondaryFixed, colors.primary500Main],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0.2, 1],
    );
    final heightFactor = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colors.neutral400.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          AppLogo(size: heightFactor * 0.2),
          3.hSpace,
          Text(
            LangKeys.onBoardingTitleKey.tr(),
            style: AppTextStyles.style24Bold.copyWith(
              color: colors.black,
              fontSize: heightFactor * 0.03,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              spacing: 5,
              children: [
                IntrinsicWidth(
                  child: Column(
                    spacing: 2,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        LangKeys.thatSuitKey.tr(),
                        style: AppTextStyles.style24SemiBold.copyWith(
                          height: 1,
                          fontSize: heightFactor * 0.03,
                          foreground: Paint()
                            ..shader = screenGradient.createShader(
                              const Rect.fromLTWH(0, 0, 300, 70),
                            ),
                        ),
                      ),
                      Container(
                        height: 5,
                        decoration: BoxDecoration(gradient: screenGradient),
                      ),
                    ],
                  ),
                ),
                IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        LangKeys.youKey.tr(),
                        style: AppTextStyles.style24SemiBold.copyWith(
                          height: 1,
                          fontSize: heightFactor * 0.03,
                          color: colors.primary500Main,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: heightFactor * 0.015),
                        height: 5,
                        color: colors.primary500Main,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          2.hSpace,
          Text(
            LangKeys.onBoardingSubTitleKey.tr(),
            style: AppTextStyles.style12Medium.copyWith(
              color: colors.black.withValues(alpha: 0.8),
              fontSize: heightFactor * 0.015,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          4.hSpace,
          AspectRatio(
            aspectRatio: 7,
            child: PrimaryGradientAppButton(
              onTap: () => context.pushNamed(AppRoutes.phoneVerificationScreen),
              title: LangKeys.loginKey.tr(),
              buttonGradient: screenGradient,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: heightFactor * 0.01),
            child: OrDivider(),
          ),
          AspectRatio(
            aspectRatio: 7,
            child: UnPrimaryGradientAppButton(
              title: LangKeys.continueAsGuestKey.tr(),
              isLoading: isGuestTokenLoading,
              onTap: () {
                ref
                    .read(generateGuestTokenProvider.notifier)
                    .generateGuestToken();
              },
              buttonGradient: screenGradient,
            ),
          ),
        ],
      ),
    );
  }
}
