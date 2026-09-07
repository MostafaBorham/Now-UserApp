import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

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
/// [onLogin] is left to the caller so the login flow can be wired separately.
class SettingsGuestView extends StatelessWidget {
  const SettingsGuestView({super.key, this.onLogin});

  /// Called when the "login / create account" button is tapped.
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome discount banner (embedded raster + vector, used as-is).
        Assets.media.images.svg.guestWelcomeDiscountImg.svg(
          height: 243,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        PrimaryAppButton(
          title: LangKeys.loginOrRegisterKey.tr(),
          titleStyle: AppTextStyles.style16Bold,
          onTap: onLogin,
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
