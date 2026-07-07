import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'components/info_field.dart';
import 'components/primary_button.dart';
import 'components/profile_avatar.dart';
import 'components/profile_header.dart';
import 'edit_information_screen.dart';

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

  static const double _hPadding = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommonHeader(
            title: 'Personal Information',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const ProfileAvatar(size: 112),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPadding),
                    child: Column(
                      children: [
                        Material(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoField(
                                  label: 'Full Name',
                                  value: 'Guest 123',
                                ),
                                InfoField(
                                  label: 'Phone',
                                  value: '(239) 555-0108',
                                ),
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
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditInformationScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
