import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';

/// White, shadowed field with a leading mobile icon, a small "Mobile Number"
/// label and a phone-number input.
///
/// Validates the input against the Saudi mobile format (`+9665XXXXXXXX`,
/// spaces and dashes ignored) and reports the result via [onValidChanged]
/// whenever the validity flips. Parents don't need to know the rule — they
/// only receive a `bool` to drive their button state.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    this.controller,
    this.hint,
    this.onValidChanged,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<bool>? onValidChanged;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  bool _lastIsValid = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant PhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final String raw = widget.controller?.text ?? '';
    final bool isValid = AppValidator.saudiPhoneToInternational(raw) != null;
    if (isValid != _lastIsValid) {
      _lastIsValid = isValid;
      widget.onValidChanged?.call(isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: context.colors.neutral200),
        boxShadow: AppBoxShadows.greyElevation2,
      ),
      child: Row(
        children: [
          Assets.media.images.svg.mobile.svg(width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.mobileNumberKey.tr(),
                  style: AppTextStyles.style14Regular.copyWith(
                    color: context.colors.neutral500,
                  ),
                ),
                TextFormField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  // The number reads left-to-right in both locales so the
                  // "(05)" head stays on the correct side of the digits.
                  textDirection: TextDirection.ltr,
                  inputFormatters: const [_SaudiPhonePrefixFormatter()],
                  style: AppTextStyles.style16Medium.copyWith(
                    color: context.colors.tertiaryContainer,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: "",
                    isCollapsed: true,
                    hintText: widget.hint ?? '(05) 555-0108',
                    hintStyle: AppTextStyles.style16Medium.copyWith(
                      color: context.colors.neutral500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps the field showing a fixed `(05) ` head in front of whatever the user
/// types: the prefix appears with the first digit and disappears again once
/// every typed digit is deleted, so the placeholder can show through.
///
/// The stored text stays human-readable (`(05) 12345678`); callers turn it
/// into the backend's `+9665XXXXXXXX` with [AppValidator.saudiPhoneToInternational].
class _SaudiPhonePrefixFormatter extends TextInputFormatter {
  const _SaudiPhonePrefixFormatter();

  static const String _prefix = '(05) ';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // The prefix already carries the leading "05" — drop it so only the
    // 8 significant digits remain.
    if (newValue.text.startsWith(_prefix) && digits.startsWith('05')) {
      digits = digits.substring(2);
    }
    // A full local/international paste still carries its own 05/966 head.
    final String? tail = AppValidator.saudiLocalPhoneTail(digits);
    final String significant =
        tail ?? (digits.length > 8 ? digits.substring(0, 8) : digits);

    if (significant.isEmpty) return TextEditingValue.empty;

    final String text = '$_prefix$significant';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
