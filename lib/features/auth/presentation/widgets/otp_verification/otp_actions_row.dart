import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// "I did not receive the code (mm:ss) Resend" with a live countdown, plus a
/// "Paste Code" pill. Resend only fires once the countdown reaches zero, then
/// the countdown restarts from whatever the backend asked for.
class OtpActionsRow extends StatefulWidget {
  const OtpActionsRow({
    super.key,
    required this.onResend,
    required this.onPaste,
    this.countdown = const Duration(seconds: 60),
  });

  /// Sends a new code. Resolves the seconds to wait before the next resend
  /// when a code is on its way, or null when nothing was sent — a failed
  /// resend must not restart the wait, or the user is locked out of retrying
  /// by a request that never happened.
  final Future<int?> Function() onResend;

  /// Fires with the digits extracted from the clipboard when "Paste Code" is
  /// tapped. Empty if the clipboard holds no digits.
  final ValueChanged<String> onPaste;

  /// The wait before the first resend.
  final Duration countdown;

  @override
  State<OtpActionsRow> createState() => _OtpActionsRowState();
}

class _OtpActionsRowState extends State<OtpActionsRow> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _isResending = false;
  late final TapGestureRecognizer _resendRecognizer = TapGestureRecognizer()
    ..onTap = _onResendTap;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.countdown.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_secondsLeft <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _restartCountdown(int seconds) {
    setState(() => _secondsLeft = seconds);
    _startTimer();
  }

  Future<void> _onResendTap() async {
    if (_secondsLeft > 0 || _isResending) return;

    setState(() => _isResending = true);

    int? retryAfterSeconds;
    try {
      retryAfterSeconds = await widget.onResend();
    } finally {
      if (mounted) setState(() => _isResending = false);
    }

    // Only restart the wait when a code really is on its way. The countdown
    // used to restart regardless, so an offline or rate-limited resend left the
    // user watching a timer for a message that was never on its way.
    if (retryAfterSeconds != null && mounted) {
      _restartCountdown(retryAfterSeconds);
    }
  }

  Future<void> _onPasteTap() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String digits = (data?.text ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    widget.onPaste(digits);
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
    final bool canResend = _secondsLeft == 0 && !_isResending;
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.style12SemiBold.copyWith(
                color: context.colors.tertiaryContainer,
              ),
              children: [
                TextSpan(text: '${LangKeys.didNotReceiveCodeKey.tr()} '),
                TextSpan(
                  text: '($_formatted) ',
                  style: TextStyle(color: context.colors.primary500Main),
                ),
                TextSpan(
                  text: LangKeys.resendKey.tr(),
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: canResend
                        ? context.colors.tertiaryContainer
                        : context.colors.neutral500,
                  ),
                  recognizer: _resendRecognizer,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _PasteCodeButton(onTap: _onPasteTap),
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
          color: context.colors.primary100,
          borderRadius: AppBorderRadius.brCircular12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.media.images.svg.clipboard.svg(
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                context.colors.primary500Main,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              LangKeys.pasteCodeKey.tr(),
              style: AppTextStyles.style14Medium.copyWith(
                color: context.colors.primary500Main,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
