import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

import 'app_colors.dart';
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
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Horizontal padding shared by the sections and the log out button.
  static const double _hPadding = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Column(
            mainAxisSize: .min,
            children: [
              const CommonHeader(),
              const SizedBox(height: 24),
              const ProfileInfo(),
              const SizedBox(height: 32),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: _hPadding),
              child: Column(
                children: [
                  SettingsSection(
                    title: 'General',
                    items: [
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.personalInfo.path,
                        label: 'Personal Information',
                        onTap: () => context.pushNamed(AppRoutes.personalInformationScreen,
                        ),
                      ),
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.myAddress.path,
                        label: 'My Address',
                        onTap: () => context.pushNamed(AppRoutes.myAddressScreen,
                        ),
                      ),
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.language.path,
                        label: 'Language',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SettingsSection(
                    title: 'Promotional Activity',
                    items: [
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.discount.path,
                        label: 'Discount Code',
                        onTap: () => context.pushNamed(AppRoutes.discountCodeScreen,
                        ),
                      ),
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.wallet.path,
                        label: 'My Wallet',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SettingsSection(
                    title: 'Support',
                    items: [
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.liveChat.path,
                        label: 'Live Chat',
                        onTap: () => context.pushNamed(AppRoutes.supportScreen,
                        ),
                      ),
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.faq.path,
                        label: 'FAQ',
                        onTap: () => context.pushNamed(AppRoutes.faqScreen,
                        ),
                      ),
                      SettingsItem(
                        iconAsset: Assets.media.images.svg.privacy.path,
                        label: 'Privacy Policy',
                        onTap: () => context.pushNamed(AppRoutes.privacyPolicyScreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  LogoutButton(onPressed: () {}),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
