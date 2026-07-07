/*
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

class CartBrandItemCard extends StatelessWidget {
  const CartBrandItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ExpansionTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          CircularBrandLogo(
            radius: 20,
            logoUrl:
                'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
          ),
          Expanded(
            child: Text('Banda Store',style: AppTextStyles.style16Medium.copyWith(
              color: colors.onSecondary
            ),),
          )
        ],
      ),
      backgroundColor: colors.onSurface.withValues(alpha: 0.2),
    );
  }
}*/
