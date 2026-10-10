import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/request_otp_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/verify_otp_vm.dart';

import '../widgets/otp_verification/otp_actions_row.dart';
import '../widgets/otp_verification/otp_code_field.dart';
import '../widgets/shared/verification_headline.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.retryAfterSeconds,
  });

  final String phoneNumber;

  /// How long until the first resend — the full window after a fresh code, or
  /// what is left of it when the backend said one had just been sent.
  final int retryAfterSeconds;

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
    // A clipboard with no digits used to wipe what the user had typed.
    if (digits.isEmpty) return;
    _otpController.text = digits;
  }

  void _leaveVerificationFlow() {
    final GoRouter router = GoRouter.of(context);

    if (router.canPop()) router.pop();
    if (router.canPop()) router.pop();

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
    ref.listen<AsyncValue<UserModel?>>(verifyOtpProvider, (
      AsyncValue<UserModel?>? previous,
      AsyncValue<UserModel?> next,
    ) {
      next.whenOrNull(
        data: (UserModel? user) {
          if (user == null) return;

          // A user the server says has not finished onboarding goes to the
          // completion screen instead of back into the app — including the
          // guest who was sent here mid-flow. `goNamed` resets the stack on
          // purpose: that screen must not be escapable backwards.
          if (!user.profileCompleted) {
            context.goNamed(AppRoutes.completeProfileScreen);
            return;
          }

          _leaveVerificationFlow();
        },
        error: (Object error, StackTrace stackTrace) =>
            AppToast.showError(context, error.toString()),
      );
    });
    final bool isVerifyOtpLoading = ref.watch(verifyOtpProvider).isLoading;

    // No leaving while the code is verified. The loading state spans the
    // session switch too, so Back used to land a signed-in user on the guest
    // phone screen with the profile gate skipped, or let the answer pop
    // screens that were no longer this flow's.
    return PopScope(
      canPop: !isVerifyOtpLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
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
                            text:
                                '\u{2066}${AppValidator.saudiPhoneToInternational(widget.phoneNumber) ?? widget.phoneNumber}\u{2069}.',
                            style: AppTextStyles.style16SemiBold.copyWith(
                              color: context.colors.primary500Main,
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

                  // Resend runs on its *own* instance of the provider. The phone
                  // screen underneath is still mounted and still listening to the
                  // shared one, and it pushes this screen whenever that provider
                  // reports a sent code — so sharing it would stack a second OTP
                  // screen on every resend. Overriding it here keeps the two apart.
                  ProviderScope(
                    overrides: [
                      requestOtpProvider.overrideWith(
                        (Ref ref) => RequestOtpViewModel(),
                      ),
                    ],
                    child: Consumer(
                      builder: (context, WidgetRef ref, _) {
                        // Nothing else watches this scoped instance, so without
                        // this the resend was completely silent: a rate-limited or
                        // offline attempt looked exactly like a successful one.
                        ref.listen<AsyncValue<OtpSent?>>(requestOtpProvider, (
                          AsyncValue<OtpSent?>? previous,
                          AsyncValue<OtpSent?> next,
                        ) {
                          next.whenOrNull(
                            error: (Object error, StackTrace stackTrace) =>
                                AppToast.showError(context, error.toString()),
                          );
                        });

                        return OtpActionsRow(
                          countdown: Duration(
                            seconds: widget.retryAfterSeconds,
                          ),
                          onResend: () async {
                            await ref
                                .read(requestOtpProvider.notifier)
                                .requestOtp(widget.phoneNumber);

                            if (!context.mounted) return null;
                            return ref
                                .read(requestOtpProvider)
                                .valueOrNull
                                ?.retryAfterSeconds;
                          },
                          onPaste: _pasteCode,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryAppButton(
                    title: LangKeys.continueKey.tr(),
                    isDisabled: !_isCodeComplete && !isVerifyOtpLoading,
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
        ),
      ),
    );
  }
}
