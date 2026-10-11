import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/formatters/arabic_kashida_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_welcome_voucher_vm.dart';

import 'language_bottom_sheet.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

/// Guest variant of the settings screen body: a welcome discount banner, a
/// login / create-account call to action, and the subset of settings a guest
/// can reach (language, FAQs, privacy policy).
///
/// The rows reuse [SettingsSection] / [SettingsTile] with the exact same
/// behaviour as the logged-in settings screen — the language row opens the
/// shared [LanguageBottomSheet], FAQs and privacy push their existing routes.
/// The login / create-account button pushes the phone verification screen.
class SettingsGuestView extends ConsumerWidget {
  const SettingsGuestView({super.key});

  // Art aspect ratio + the motorbike's placement rect inside the 234x254
  // source artwork (the `guest-welcome-discount-img.svg` viewBox).
  static const double _artWidth = 234;
  static const double _artHeight = 254;
  static const double _bikeTop = 15.7188;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    // The badge promo code comes from the same first-order welcome voucher the
    // empty cart shows; fall back to the canonical code until it loads.
    final String? apiCode =
        ref.watch(welcomeVoucherProvider).valueOrNull?.code;
    final String promoCode = (apiCode != null && apiCode.isNotEmpty)
        ? apiCode
        : welcomeVoucherCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top spacing lives inside the scroll view (owned by SettingsScreen)
        // so it scrolls up with the content.
        const SizedBox(height: 57),
        // Welcome discount banner: the SVG carries the "BIG DISCOUNT / خصم
        // كبير" lettering as vectors, but its motorbike is a raster inside an
        // SVG <pattern> that flutter_svg can't paint — so the same cutout is
        // overlaid as a PNG, positioned to match its rect in the artwork.
        Center(
          child: SizedBox(
            height: 243,
            width: 243 * _artWidth / _artHeight,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Assets.media.images.svg.guestWelcomeDiscountImg.svg(
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      top: constraints.maxHeight * (_bikeTop / _artHeight),
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Assets
                          .media
                          .images
                          .png
                          .guestWelcomeDiscountMotorbike
                          .image(fit: BoxFit.fill),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Promo strip: "promo code" + WELCOME badge on the start side, "on
        // first order" on the end side.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatArabicKashida(LangKeys.promoCodeKey.tr(), count: 4),
                    style: AppTextStyles.style12SemiBold.copyWith(
                      color: colors.primary500Main,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: RadialGradient(
                        colors: [
                          colors.surfaceContainerHighest,
                          colors.surfaceContainerHigh,
                          colors.onSecondaryFixed,
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                    child: Text(
                      promoCode,
                      style: AppTextStyles.style12Bold.copyWith(
                        color: colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                formatArabicKashida(LangKeys.onFirstOrderKey.tr(), count: 4),
                textAlign: TextAlign.center,
                style: AppTextStyles.style12SemiBold.copyWith(
                  color: colors.primary500Main,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryAppButton(
          title: LangKeys.loginOrRegisterKey.tr(),
          titleStyle: AppTextStyles.style16Bold,
          onTap: () => context.pushNamed(AppRoutes.phoneVerificationScreen),
        ),
        const SizedBox(height: 20),
        SettingsSection(
          items: [
            SettingsItem(
              iconAsset: Assets.media.images.svg.language.path,
              label: LangKeys.language.tr(),
              onTap: () => LanguageBottomSheet.show(context),
            ),
            SettingsItem(
              iconAsset: Assets.media.images.svg.faq.path,
              label: LangKeys.faqs.tr(),
              onTap: () => context.pushNamed(AppRoutes.faqScreen),
            ),
            SettingsItem(
              iconAsset: Assets.media.images.svg.privacy.path,
              label: LangKeys.privacyPolicy.tr(),
              onTap: () => context.pushNamed(AppRoutes.privacyPolicyScreen),
            ),
          ],
        ),
      ],
    );
  }
}
