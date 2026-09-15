import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';




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
