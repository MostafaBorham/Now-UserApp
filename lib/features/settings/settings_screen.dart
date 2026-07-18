import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/logout_vm.dart';

import 'app_colors.dart';
import 'components/language_bottom_sheet.dart';
import 'components/logout_button.dart';
import 'components/profile_header.dart';
import 'components/profile_info.dart';
import 'components/settings_section.dart';
import 'components/settings_tile.dart';

/// Profile screen.
///
/// Composed of independent sections (see `components/`):
///   1. [CommonHeader]  – yellow header + wave + title
///   2. [ProfileInfo]    – avatar, name and "member since" date
///   3. [SettingsSection] x3 – General / Promotional Activity / Support
///   4. [LogoutButton]   – red log out action
///
/// The bottom navigation bar is intentionally NOT included here.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    ref.listen<AsyncValue<dynamic>>(logoutProvider,
        (AsyncValue<dynamic>? previous, AsyncValue<dynamic> next) {
      next.whenOrNull(
        // Logged out: reset the stack so onboarding is the only screen left.
        data: (dynamic value) {
          if (value != null) {
            context.goNamed(AppRoutes.onBoardingScreen);
          }
        },
        error: (Object error, StackTrace stackTrace) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  error.toString().tr(),
                  style: AppTextStyles.style16SemiBold.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                elevation: 4,
                padding: const EdgeInsets.all(16),
                backgroundColor: colors.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            );
        },
      );
    });

    final bool isLoggingOut = ref.watch(logoutProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedScaffold(
        appBarTitle: LangKeys.profileKey.tr(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ProfileInfo(),
              const SizedBox(height: 32),
              SettingsSection(
                title: LangKeys.general.tr(),
                items: [
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.personalInfo.path,
                    label: LangKeys.personalInformationKey.tr(),
                    onTap: () =>
                        context.pushNamed(AppRoutes.personalInformationScreen),
                  ),
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.myAddress.path,
                    label: LangKeys.myAddress.tr(),
                    onTap: () => context.pushNamed(AppRoutes.myAddressScreen),
                  ),
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.language.path,
                    label: LangKeys.language.tr(),
                    onTap: () => LanguageBottomSheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSection(
                title: LangKeys.proActivity.tr(),
                items: [
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.discount.path,
                    label: LangKeys.discount.tr(),
                    onTap: () =>
                        context.pushNamed(AppRoutes.discountCodeScreen),
                  ),
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.wallet.path,
                    label: LangKeys.myWallet.tr(),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSection(
                title: LangKeys.supportLabel.tr(),
                items: [
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.liveChat.path,
                    label: LangKeys.liveChat.tr(),
                    onTap: () => context.pushNamed(AppRoutes.supportScreen),
                  ),
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.faq.path,
                    label: LangKeys.faqs.tr(),
                    onTap: () => context.pushNamed(AppRoutes.faqScreen),
                  ),
                  SettingsItem(
                    iconAsset: Assets.media.images.svg.privacy.path,
                    label: LangKeys.privacyPolicy.tr(),
                    onTap: () =>
                        context.pushNamed(AppRoutes.privacyPolicyScreen),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              LogoutButton(
                isLoading: isLoggingOut,
                onPressed: () => ref.read(logoutProvider.notifier).logout(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
