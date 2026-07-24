import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

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
  /// Saudi mobile number with country code: +966 5XXXXXXXX
  /// (spaces and dashes are ignored when validating).
  static final RegExp _saudiPhoneRegExp = RegExp(r'^\+9665\d{8}$');

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
    final bool isValid = _saudiPhoneRegExp.hasMatch(
      raw.replaceAll(RegExp(r'[\s-]'), ''),
    );
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
        border: Border.all(color: AppColors.outlinedButtonBorder),
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
                    color: AppColors.mutedLabel,
                  ),
                ),
                TextFormField(
                  controller: widget.controller,
                  maxLength: 14,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.style16Medium.copyWith(
                    color: AppColors.optionTitle,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: "",
                    isCollapsed: true,
                    hintText: widget.hint ?? '+966 5X XXX XXXX',
                    hintStyle: AppTextStyles.style16Medium.copyWith(
                      color: AppColors.mutedLabel,
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
