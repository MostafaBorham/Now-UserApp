import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

/// "I did not receive the code (mm:ss) Resend" with a live countdown, plus a
/// "Paste Code" pill. Resend only fires once the countdown reaches zero, then
/// the countdown restarts.
class OtpActionsRow extends StatefulWidget {
  const OtpActionsRow({
    super.key,
    required this.onResend,
    required this.onPaste,
    this.countdown = const Duration(seconds: 30),
  });

  final VoidCallback onResend;
  final VoidCallback onPaste;
  final Duration countdown;

  @override
  State<OtpActionsRow> createState() => _OtpActionsRowState();
}

class _OtpActionsRowState extends State<OtpActionsRow> {
  Timer? _timer;
  int _secondsLeft = 0;
  late final TapGestureRecognizer _resendRecognizer =
      TapGestureRecognizer()..onTap = _onResendTap;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.countdown.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _restartCountdown() {
    setState(() => _secondsLeft = widget.countdown.inSeconds);
    _startTimer();
  }

  void _onResendTap() {
    if (_secondsLeft > 0) return;
    widget.onResend();
    _restartCountdown();
  }

  String get _formatted {
    final String m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final String s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canResend = _secondsLeft == 0;
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.style12SemiBold.copyWith(
                color: AppColors.sectionTitle,
              ),
              children: [
                TextSpan(text: '${LangKeys.didNotReceiveCodeKey.tr()} '),
                TextSpan(
                  text: '($_formatted) ',
                  style: TextStyle(color: AppColors.selectedIndicator),
                ),
                TextSpan(
                  text: LangKeys.resendKey.tr(),
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: canResend
                        ? AppColors.sectionTitle
                        : AppColors.mutedLabel,
                  ),
                  recognizer: _resendRecognizer,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _PasteCodeButton(onTap: widget.onPaste),
      ],
    );
  }
}

class _PasteCodeButton extends StatelessWidget {
  const _PasteCodeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.brCircular12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.pasteCodeBackground,
          borderRadius: AppBorderRadius.brCircular12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.media.images.svg.clipboard.svg(
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.selectedIndicator,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              LangKeys.pasteCodeKey.tr(),
              style: AppTextStyles.style14Medium.copyWith(
                color: AppColors.selectedIndicator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
