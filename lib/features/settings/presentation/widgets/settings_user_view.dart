import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/logout_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

import 'language_bottom_sheet.dart';
import 'profile_info.dart';
import 'profile_info_shimmer.dart';
import 'settings_section.dart';
import 'settings_tile.dart';
import 'wallet_and_promotion_summary_widget.dart';

/// Signed-in settings with a profile header, balance summary and grouped rows.
class SettingsUserView extends ConsumerWidget {
  const SettingsUserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoggingOut = ref.watch(
      logoutProvider.select((state) => state.isLoading),
    );
    // Fetched once when the session resolves and shared with the Personal
    // Information screen.
    final AsyncValue<PersonalInformationData> profile = ref.watch(
      getProfileProvider,
    );

    return Column(
      children: [
        // While loading, show a same-size shimmer avatar + name bar instead of
        // the default placeholder, then swap in the real picture and name.
        profile.when(
          loading: () => const ProfileInfoShimmer(),
          // A blank name with no way back looked like an empty profile
          // (QA-003 A17): say so, and retry on tap.
          error: (_, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(getProfileProvider.notifier).getProfile(),
            child: Column(
              spacing: 8,
              children: [
                const ProfileInfo(name: ''),
                Text(
                  LangKeys.profileLoadFailedKey.tr(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style14Medium.copyWith(
                    color: context.colors.errorContainer,
                  ),
                ),
              ],
            ),
          ),
          data: (PersonalInformationData data) => ProfileInfo(
            name: data.profile.fullName ?? '',
            avatarUrl: data.avatarUrl,
          ),
        ),
        const SizedBox(height: 16),
        const WalletAndPromotionSummaryWidget(),
        const SizedBox(height: 24),
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
              iconAsset: Assets.media.images.svg.myAddresses.path,
              label: LangKeys.myAddressesKey.tr(),
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
              label: LangKeys.discountCodes.tr(),
              onTap: () => context.pushNamed(AppRoutes.discountCodeScreen),
            ),
            SettingsItem(
              iconAsset: Assets.media.images.svg.rewardPointsIcon.path,
              iconColor: context.colors.tertiaryContainer,
              label: LangKeys.rewardPointsKey.tr(),
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
              iconAsset: Assets.media.images.svg.chatTypingIcon.path,
              label: LangKeys.supportAndComplaintsKey.tr(),
              onTap: () =>
                  context.pushNamed(AppRoutes.supportAndComplaintsScreen),
            ),
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
              onTap: () => context.pushNamed(AppRoutes.privacyPolicyScreen),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          title: LangKeys.dangerZoneKey.tr(),
          isDanger: true,
          items: [
            SettingsItem(
              iconAsset: Assets.media.images.svg.logout.path,
              label: LangKeys.logout.tr(),
              isLoading: isLoggingOut,
              onTap: () => AppCustomAlertDialog.show(
                context,
                (BuildContext dialogContext) => AppCustomAlertDialog(
                  title: LangKeys.logout.tr(),
                  message: LangKeys.logoutConfirmationKey.tr(),
                  confirmLabel: LangKeys.logout.tr(),
                  onConfirm: () {
                    dialogContext.pop();
                    ref.read(logoutProvider.notifier).logout();
                  },
                ),
              ),
            ),
            SettingsItem(
              iconAsset: Assets.media.images.svg.deleteIcon.path,
              label: LangKeys.deleteAccountKey.tr(),
            ),
          ],
        ),
      ],
    );
  }
}
