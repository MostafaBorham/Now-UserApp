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
import 'package:nowdelivery_user_app/core/presentation/assets/fonts.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
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
            AppToast.showError(context, error.toString()),
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
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final TextStyle headlineStyle = AppTextStyles.style24Bold.copyWith(
      fontFamily: FontFamily.cairo,
      fontWeight: FontWeight.w800,
      color: colors.tertiaryContainer,
      overflow: TextOverflow.visible,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20 + bottomInset),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LangKeys.onBoardingTitleKey.tr(),
                style: headlineStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                LangKeys.onBoardingSubTitleKey.tr(),
                style: headlineStyle,
                textAlign: TextAlign.center,
              ),
            ],
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
