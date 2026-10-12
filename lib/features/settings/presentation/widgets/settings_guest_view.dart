import 'package:easy_localization/easy_localization.dart' hide TextDirection;
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

  // Art aspect ratio: the `guest-welcome-discount-img.svg` viewBox.
  static const double _artWidth = 234;
  static const double _artHeight = 254;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    // The badge promo code comes from the same first-order welcome voucher the
    // empty cart shows. With no live code there is no offer to advertise, so
    // the banner goes — it used to fall back to a hardcoded WELCOME10 that the
    // admin may have switched off (BUG-022).
    final String? promoCode = ref
        .watch(welcomeVoucherProvider)
        .valueOrNull
        ?.code;
    final bool hasCode = promoCode != null && promoCode.isNotEmpty;
    final double stripInset =
        Directionality.of(context) == TextDirection.rtl ? 18 : 8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top spacing lives inside the scroll view (owned by SettingsScreen)
        // so it scrolls up with the content.
        const SizedBox(height: 57),
        if (hasCode) ...[
          // Welcome discount banner, Figma 9226:44555 (ar) / 9983:111537 (en):
          // a 243-high frame whose art (234x254) runs past its bottom edge,
          // with the promo strip sitting on that edge, over the art's empty
          // bottom. The SVG is the "BIG DISCOUNT / خصومات كبيرة" lettering; the
          // motorbike PNG spans the art's width at its own aspect ratio.
          SizedBox(
            height: 243,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: _artWidth,
                      height: _artHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Assets.media.images.svg.guestWelcomeDiscountImg.svg(
                            fit: BoxFit.fill,
                          ),
                          Assets.media.images.png.guestWelcomeDiscountMotorbike
                              .image(
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.bottomCenter,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Promo strip: "promo code" + code badge on the start side,
                // "on the first order" (two lines) on the end side. The two
                // frames inset it differently: 18 from the edges in Arabic,
                // 8 in English (its labels are wider).
                Positioned(
                  left: stripInset,
                  right: stripInset,
                  bottom: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatArabicKashida(
                              LangKeys.promoCodeKey.tr(),
                              count: 4,
                            ).toUpperCase(),
                            style: AppTextStyles.style12SemiBold.copyWith(
                              color: colors.primary500Main,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: RadialGradient(
                                colors: [
                                  colors.surfaceContainerHighest,
                                  colors.surfaceContainerHigh,
                                  colors.onSecondaryFixed,
                                ],
                                stops: const [0, 0.5, 1],
                                transform: const _StretchToWidth(),
                              ),
                            ),
                            child: Text(
                              promoCode,
                              style: AppTextStyles.style12Bold.copyWith(
                                color: colors.black,
                                height: 1.5,
                                leadingDistribution:
                                    TextLeadingDistribution.even,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formatArabicKashida(
                          LangKeys.onFirstOrderKey.tr(),
                          count: 8,
                        ).toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style12SemiBold.copyWith(
                          color: colors.primary500Main,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
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

/// Stretches a [RadialGradient] horizontally so it spreads as an ellipse
/// touching all four edges of its box, the way Figma draws the badge's
/// gradient (Flutter's radius is a circle sized by the shortest side).
class _StretchToWidth extends GradientTransform {
  const _StretchToWidth();

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final double sx = bounds.width / bounds.height;
    // Scale x by sx around the box's centre.
    return Matrix4.diagonal3Values(sx, 1, 1)
      ..setTranslationRaw(bounds.center.dx * (1 - sx), 0, 0);
  }
}
