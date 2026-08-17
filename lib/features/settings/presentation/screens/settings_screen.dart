import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/logout_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

import '../widgets/language_bottom_sheet.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_info.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<dynamic>>(logoutProvider, (
      AsyncValue<dynamic>? previous,
      AsyncValue<dynamic> next,
    ) {
      next.whenOrNull(
        // Logged out: reset the stack so onboarding is the only screen left.
        data: (dynamic value) {
          if (value != null) {
            context.goNamed(AppRoutes.onBoardingScreen);
          }
        },
        error: (Object error, StackTrace stackTrace) =>
            ErrorSnackBar.show(context, error.toString()),
      );
    });

    final bool isLoggingOut = ref.watch(logoutProvider).isLoading;
    final bool isUser =
        ref.watch(authSessionProvider.select((s) => s.sessionType)) ==
        SessionType.user;
    // Fetched once and shared with the Personal Information screen; only for
    // logged-in users (guests have no /user/profile).
    final profileData =
        isUser ? ref.watch(getProfileProvider).valueOrNull : null;

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.profileKey.tr(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Logged-in users see their real name + avatar; guests keep the
              // default label and never hit /user/profile.
              isUser
                  ? ProfileInfo(
                      name: profileData?.profile.fullName ?? '',
                      avatarUrl: profileData?.avatarUrl,
                    )
                  : const ProfileInfo(),
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
                    onTap: () => context.pushNamed(AppRoutes.walletScreen),
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
              15.hSpace,
              if (isUser)
                LogoutButton(
                  isLoading: isLoggingOut,
                  // Confirm first; the dialog closes as soon as the user
                  // confirms and the request's progress is shown on the button
                  // itself (the listener above handles success / failure).
                  onPressed: () => AppCustomAlertDialog.show(
                    context,
                    (BuildContext dialogContext) => AppCustomAlertDialog(
                      title: LangKeys.logout.tr(),
                      message: LangKeys.logoutConfirmationKey.tr(),
                      confirmLabel: LangKeys.logout.tr(),
                      onConfirm: () {
                        Navigator.of(dialogContext).pop();
                        ref.read(logoutProvider.notifier).logout();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
