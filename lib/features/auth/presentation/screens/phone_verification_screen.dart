import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/request_otp_vm.dart';

import '../widgets/phone_verification/phone_number_field.dart';
import '../widgets/shared/verification_headline.dart';

/// Step 1 of login: collect the mobile number to send an OTP to.
class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool _isPhoneValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    ref.listen<AsyncValue<String?>>(requestOtpProvider,
        (AsyncValue<String?>? previous, AsyncValue<String?> next) {
      next.whenOrNull(
        data: (String? phone) {
          if (phone != null) {
            context.pushNamed(AppRoutes.otpVerificationScreen, extra: phone);
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
                padding: EdgeInsets.all(16),
                backgroundColor: colors.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(100),
                ),
              ),
            );
        },
      );
    });
    final bool isRequestOtpLoading = ref.watch(requestOtpProvider).isLoading;

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
              PhoneNumberField(
                controller: _phoneController,
                onValidChanged: (bool isValid) =>
                    setState(() => _isPhoneValid = isValid),
              ),
              const SizedBox(height: 28),
              isRequestOtpLoading
                  ? Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    )
                  : !_isPhoneValid
                      ? PrimaryAppDisabledButton(
                          title: LangKeys.continueKey.tr(),
                          buttonPadding: 16,
                        )
                      : PrimaryAppButton(
                          title: LangKeys.continueKey.tr(),
                          buttonPadding: 16,
                          onTap: () {
                            ref
                                .read(requestOtpProvider.notifier)
                                .requestOtp(_phoneController.text.trim());
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
