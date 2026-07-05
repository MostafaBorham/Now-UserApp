import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/route/app_routes.dart';

import '../widgets/personal_information/personal_info_form.dart';
import '../widgets/personal_information/profile_avatar_picker.dart';

/// Step 3 of guest verification: optionally add a photo and name before
/// entering the app.
class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  void _finish(BuildContext context) => Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.mainLayoutScreen,
    (route) => false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWavedScaffold(
        appBarTitle: LangKeys.personalInformationKey.tr(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Center(child: ProfileAvatarPicker()),
                    const SizedBox(height: 32),
                    const PersonalInfoForm(),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: PrimaryAppButton(
                    title: LangKeys.continueKey.tr(),
                    buttonPadding: 16,
                    onTap: () => _finish(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UnPrimaryButton(
                    title: LangKeys.skipKey.tr(),
                    buttonPadding: 16,
                    onTap: () => _finish(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
