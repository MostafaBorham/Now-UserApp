import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/saudi_phone_input_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/focus_ring.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

/// White, shadowed field with a leading mobile icon, a small "Mobile Number"
/// label and a phone-number input.
///
/// Valid once exactly 8 digits follow the `(05)` head
/// ([SaudiPhoneInputFormatter.isComplete]); the result is reported via
/// [onValidChanged] whenever the validity flips. Parents don't need to know the
/// rule — they only receive a `bool` to drive their button state.
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
    final bool isValid = SaudiPhoneInputFormatter.isComplete(
      widget.controller?.text,
    );
    if (isValid != _lastIsValid) {
      _lastIsValid = isValid;
      widget.onValidChanged?.call(isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusRing(
      borderRadius: AppBorderRadius.brCircular16,
      child: Container(
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
                    contextMenuBuilder: appContextMenuBuilder,
                    controller: widget.controller,
                    keyboardType: TextInputType.phone,
                    // The number always reads left-to-right so the "(05)" head
                    // stays on the correct side of the digits, but the field
                    // aligns to the locale's start edge: left in English, right
                    // in Arabic.
                    textDirection: TextDirection.ltr,
                    textAlign: Directionality.of(context) == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                    inputFormatters: const [SaudiPhoneInputFormatter()],
                    style: AppTextStyles.style16Medium.copyWith(
                      color: context.colors.tertiaryContainer,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: "",
                      isCollapsed: true,
                      hintText: widget.hint ?? '(05) 1111-2222',
                      // Keep the hint reading left-to-right so the "(05)" head
                      // stays on the left in Arabic too — matching the order of
                      // the digits the user will actually type.
                      hintTextDirection: TextDirection.ltr,
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
      ),
    );
  }
}
