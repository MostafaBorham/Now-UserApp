import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/request_otp_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/verify_otp_vm.dart';

import '../widgets/otp_verification/otp_actions_row.dart';
import '../widgets/otp_verification/otp_code_field.dart';
import '../widgets/shared/verification_headline.dart';

/// Step 2 of login: enter the OTP sent to the phone number.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
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

  /// Exits the verification flow after a successful login.
  ///
  /// Pops this OTP screen and the phone screen beneath it so back never
  /// returns into the flow, landing on the screen the flow was opened from
  /// (e.g. payment methods or the pre-checkout screen). When there is no
  /// meaningful screen to return to — the flow was entered from onboarding
  /// or opened directly — the stack is reset to the main screen instead.
  /// Route-level redirects don't run on pop, so the onboarding case is
  /// detected and rerouted here.
  void _leaveVerificationFlow() {
    final GoRouter router = GoRouter.of(context);

    if (router.canPop()) router.pop(); // this OTP screen
    if (router.canPop()) router.pop(); // the phone screen beneath it

    final String? landedOn = router.state.topRoute?.name;
    if (landedOn == null ||
        landedOn == AppRoutes.onBoardingScreen ||
        landedOn == AppRoutes.phoneVerificationScreen ||
        landedOn == AppRoutes.otpVerificationScreen ||
        landedOn == AppRoutes.splashScreen) {
      router.goNamed(AppRoutes.mainScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    ref.listen<AsyncValue<UserModel?>>(verifyOtpProvider, (
      AsyncValue<UserModel?>? previous,
      AsyncValue<UserModel?> next,
    ) {
      next.whenOrNull(
        data: (UserModel? user) {
          if (user != null) {
            _leaveVerificationFlow();
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
    final bool isVerifyOtpLoading = ref.watch(verifyOtpProvider).isLoading;

    return Scaffold(
      body: AppWavedView(
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
              // Give the resend action its own scoped instance of
              // requestOtpProvider. The phone screen (still mounted below in
              // the stack) listens to the root instance, so a resend here does
              // not trigger its listener and re-navigate to this screen.
              ProviderScope(
                overrides: [
                  requestOtpProvider.overrideWith(
                    (Ref ref) => RequestOtpViewModel(),
                  ),
                ],
                child: Consumer(
                  builder: (context, WidgetRef ref, _) => OtpActionsRow(
                    onResend: () => ref
                        .read(requestOtpProvider.notifier)
                        .requestOtp(widget.phoneNumber),
                    onPaste: _pasteCode,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              !_isCodeComplete && !isVerifyOtpLoading
                  ? PrimaryAppDisabledButton(
                      title: LangKeys.continueKey.tr(),
                      buttonPadding: 16,
                    )
                  : PrimaryAppButton(
                      title: LangKeys.continueKey.tr(),
                      buttonPadding: 16,
                      isLoading: isVerifyOtpLoading,
                      onTap: () {
                        ref
                            .read(verifyOtpProvider.notifier)
                            .verifyOtp(
                              phone: widget.phoneNumber,
                              code: _otpController.text,
                            );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
