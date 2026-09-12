import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
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
    ref.listen<AsyncValue<String?>>(requestOtpProvider, (
      AsyncValue<String?>? previous,
      AsyncValue<String?> next,
    ) {
      next.whenOrNull(
        data: (String? phone) {
          if (phone != null) {
            context.pushNamed(AppRoutes.otpVerificationScreen, extra: phone);
          }
        },
        error: (Object error, StackTrace stackTrace) =>
            AppToast.showError(context, error.toString()),
      );
    });
    final bool isRequestOtpLoading = ref.watch(requestOtpProvider).isLoading;

    return Scaffold(
      body: AppWavedView(
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
              !_isPhoneValid && !isRequestOtpLoading
                  ? PrimaryAppDisabledButton(
                      title: LangKeys.continueKey.tr(),
                      buttonPadding: 16,
                    )
                  : PrimaryAppButton(
                      title: LangKeys.continueKey.tr(),
                      buttonPadding: 16,
                      isLoading: isRequestOtpLoading,
                      onTap: () {
                        final String? phone =
                            AppValidator.saudiPhoneToInternational(
                          _phoneController.text,
                        );
                        if (phone == null) return;
                        ref
                            .read(requestOtpProvider.notifier)
                            .requestOtp(phone);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
