import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/focus_ring.dart';

/// A single rounded input used on the Address Details form.
///
/// Shares the grey fill of the app's other inputs but uses a softer
/// rounded-rectangle radius. Its [label] sits inside the empty field and floats
/// above the text once there is some — as a plain placeholder it vanished on
/// the first keystroke, leaving filled fields unnamed.
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return FocusRing(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textDirection: textDirection,
          textAlign: textDirection == null
              ? TextAlign.start
              : Directionality.of(context) == TextDirection.rtl
              ? TextAlign.right
              : TextAlign.left,
          style: AppTextStyles.style14Regular.copyWith(
            color: context.colors.tertiaryContainer,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            labelText: label,
            labelStyle: AppTextStyles.style14Regular.copyWith(
              color: context.colors.neutral500,
            ),
          ),
        ),
      ),
    );
  }
}
