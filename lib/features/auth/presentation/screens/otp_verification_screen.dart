import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

import '../widgets/otp_verification/otp_actions_row.dart';
import '../widgets/otp_verification/otp_code_field.dart';
import '../widgets/shared/verification_headline.dart';

/// Step 2 of login: enter the OTP sent to the phone number.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();


  bool _isCodeComplete = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _pasteCode(String digits) {
    _otpController.text = digits;
  }

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
                title: LangKeys.enterVerificationCodeKey.tr(),
                subtitle: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${LangKeys.otpSentToKey.tr()} '),
                      TextSpan(
                        text: '${widget.phoneNumber}.',
                        style: AppTextStyles.style16SemiBold.copyWith(
                          color: AppColors.selectedIndicator,
                        ),
                      ),
                      const TextSpan(text: '\n'),
                      TextSpan(text: LangKeys.enterCodeToContinueKey.tr()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              OtpCodeField(
                controller: _otpController,
                onCompletionChanged: (isComplete) =>
                    setState(() => _isCodeComplete = isComplete),
              ),
              const SizedBox(height: 16),
              OtpActionsRow(onResend: () {}, onPaste: _pasteCode),
              const SizedBox(height: 28),
              if (_isCodeComplete)
                PrimaryAppButton(
                  title: LangKeys.continueKey.tr(),
                  buttonPadding: 16,
                  onTap: () =>
                      context.pushNamed(AppRoutes.orderConfirmedScreen),
                )
              else
                PrimaryAppDisabledButton(
                  title: LangKeys.continueKey.tr(),
                  buttonPadding: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
