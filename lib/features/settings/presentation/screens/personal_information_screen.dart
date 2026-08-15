import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

import '../widgets/info_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_header.dart';

/// Read-only "Personal Information" screen, shown when the user taps the
/// Personal Information tile on the profile screen.
///
/// Sections:
///   1. [CommonHeader] – back button + title
///   2. [ProfileAvatar] – circular photo placeholder
///   3. Info card       – read-only [InfoField]s
///   4. [PrimaryButton] – "Edit" → [EditInformationScreen]
class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.personalInformationKey.tr(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const ProfileAvatar(size: 112),
              const SizedBox(height: 28),
              Column(
                children: [
                  Material(
                    color: context.colors.onTertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoField(label: 'Full Name', value: 'Guest 123'),
                          InfoField(label: 'Phone', value: '(239) 555-0108'),
                          InfoField(
                            label: 'Email',
                            hint: 'Enter email address',
                          ),
                          InfoField(label: 'Gender', value: 'Male'),
                          InfoField(
                            label: 'Date of Birth',
                            hint: 'Select date of birth',
                          ),
                          InfoField(
                            label: 'Nationality',
                            hint: 'Enter your nationality',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Edit',
                    onPressed: () =>
                        context.pushNamed(AppRoutes.editInformationScreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
