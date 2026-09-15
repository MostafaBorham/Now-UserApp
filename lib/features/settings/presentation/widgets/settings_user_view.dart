import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/logout_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

import 'language_bottom_sheet.dart';
import 'logout_button.dart';
import 'profile_info.dart';
import 'profile_info_shimmer.dart';
import 'settings_section.dart';
import 'settings_tile.dart';







class SettingsUserView extends ConsumerWidget {
  const SettingsUserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<dynamic>>(logoutProvider, (
      AsyncValue<dynamic>? previous,
      AsyncValue<dynamic> next,
    ) {
      next.whenOrNull(

        data: (dynamic value) {
          if (value != null) {
            context.goNamed(AppRoutes.onBoardingScreen);
          }
        },
        error: (Object error, StackTrace stackTrace) =>
            AppToast.showError(context, error.toString()),
      );
    });

    final bool isLoggingOut = ref.watch(logoutProvider).isLoading;


    final AsyncValue<PersonalInformationData> profile =
        ref.watch(getProfileProvider);

    return Column(
      children: [


        const SizedBox(height: 57),


        profile.when(
          loading: () => const ProfileInfoShimmer(),
          error: (_, _) => const ProfileInfo(name: ''),
          data: (PersonalInformationData data) => ProfileInfo(
            name: data.profile.fullName ?? '',
            avatarUrl: data.avatarUrl,
          ),
        ),
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
              label: LangKeys.discountCodes.tr(),
              onTap: () => context.pushNamed(AppRoutes.discountCodeScreen),
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
              onTap: () => context.pushNamed(AppRoutes.privacyPolicyScreen),
            ),
          ],
        ),
        15.hSpace,
        LogoutButton(
          isLoading: isLoggingOut,



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
    );
  }
}
