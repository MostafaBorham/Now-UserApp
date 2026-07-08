import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

class LogoTitleExpansionHeader extends StatelessWidget {
  const LogoTitleExpansionHeader({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onToggle(!isExpanded),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              CircularBrandLogo(
                radius: 24,
                elevation: 1,
                backgroundColor: colors.onTertiaryContainer,
                logoUrl:
                    'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
              ),
              Text(
                'Banda Store',
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.onSecondary,
                ),
              ),
            ],
          ),
          Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: colors.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
