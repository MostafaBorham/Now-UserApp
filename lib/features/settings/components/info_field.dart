import 'package:flutter/material.dart';

import '../app_colors.dart';

/// A single read-only row on the Personal Information screen: a small grey
/// label with its value (or a greyed-out hint when empty) and an optional
/// bottom divider.
class InfoField extends StatelessWidget {
  const InfoField({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.showDivider = true,
  });

  final String label;
  final String? value;
  final String? hint;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.fieldLabel,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasValue ? value! : (hint ?? ''),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: hasValue ? AppColors.textPrimary : AppColors.hintText,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      ],
    );
  }
}
