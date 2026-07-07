import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

class CartItemExpantionHeader extends StatelessWidget {
  const CartItemExpantionHeader({
    super.key,
    this.storeName = 'Banda Store',
    this.logoUrl =
        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
    this.isExpanded = false,
    this.onTap,
  });

  final String storeName;
  final String logoUrl;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              CircularBrandLogo(
                radius: 24,
                backgroundColor: colors.onTertiaryContainer,
                logoUrl: logoUrl,
              ),
              Text(
                storeName,
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
            color: colors.onSecondary,
          ),
        ],
      ),
    );
  }
}
