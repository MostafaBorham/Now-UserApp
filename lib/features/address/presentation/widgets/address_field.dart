import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';





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



              textDirection: TextDirection.ltr,
              child: Row(
                children: [


                  Text(prefixText!, style: valueStyle),
                  const SizedBox(width: 4),
                  Expanded(child: input),
                ],
              ),
            ),
    );
  }
}
