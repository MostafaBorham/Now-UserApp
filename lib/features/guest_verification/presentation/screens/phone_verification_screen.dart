import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/route/app_routes.dart';

import '../widgets/phone_verification/phone_number_field.dart';
import '../widgets/shared/verification_headline.dart';

/// Step 1 of guest verification: collect the mobile number to send an OTP to.
class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWavedScaffold(
        appBarTitle: LangKeys.verificationCodeKey.tr(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerificationHeadline(
                title: LangKeys.verifyGuestViaPhoneKey.tr(),
                subtitle: Text(LangKeys.phoneVerificationSubtitleKey.tr()),
              ),
              const SizedBox(height: 32),
              const PhoneNumberField(),
              const SizedBox(height: 28),
              PrimaryAppButton(
                title: LangKeys.continueKey.tr(),
                buttonPadding: 16,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.otpVerificationScreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
