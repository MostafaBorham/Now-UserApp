import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// A single, label-less rounded input used on the Address Details form.
///
/// Shares the grey fill of the app's other inputs but uses a softer
/// rounded-rectangle radius and shows only placeholder ([hintText]) text.
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
  });

  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  /// A fixed, uneditable head of the value (the phone field's `05`), shown
  /// before the input. The controller holds only what follows it, so callers
  /// compose the full value themselves.
  ///
  /// This is a leading [Text] rather than `InputDecoration.prefixText` because
  /// Flutter fades affixes out while the field is empty and unfocused — exactly
  /// when the prefix needs to be visible.
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = AppTextStyles.style14Regular.copyWith(
      color: context.colors.tertiaryContainer,
    );

    final Widget input = TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: valueStyle,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: AppTextStyles.style14Regular.copyWith(
          color: context.colors.neutral500,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: prefixText == null
          ? input
          : Directionality(
              // A phone number reads left-to-right in both locales, the way the
              // app pins prices (see new_price_widget.dart) — otherwise Arabic
              // puts the prefix on the wrong side of the digits.
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  // Part of the value, so it takes the input colour rather than
                  // the hint's.
                  Text(prefixText!, style: valueStyle),
                  const SizedBox(width: 4),
                  Expanded(child: input),
                ],
              ),
            ),
    );
  }
}
