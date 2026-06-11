import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class PrimaryAppButton extends StatelessWidget {
  const PrimaryAppButton({super.key, required this.isFilled, required this.title, this.onTap});

  final bool isFilled;
  final String title;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: isFilled ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: !isFilled ? colors.primary : Colors.transparent,
                width: 2
            )
        ),
        child: AutoSizeText(
          title,
          textAlign: TextAlign.center,
          minFontSize: 10,
          style: textThemes.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isFilled ? colors.onPrimary : colors.primary,
          ),
        ),
      ),
    );
  }
}