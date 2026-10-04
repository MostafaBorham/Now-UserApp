import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

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
    this.forceLtrValue = false,
  });

  final String label;
  final String? value;
  final String? hint;
  final bool showDivider;

  /// Renders the value left-to-right regardless of the app locale. Only for
  /// values that are always Latin-script, such as the phone number — forcing it
  /// on an Arabic name or nationality misplaces their punctuation.
  final bool forceLtrValue;

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
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.neutral500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasValue ? value! : (hint ?? ''),
                textDirection: forceLtrValue ? TextDirection.ltr : null,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: hasValue
                      ? context.colors.tertiaryContainer
                      : context.colors.neutral500,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: context.colors.neutral200),
      ],
    );
  }
}
