import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/route/app_routes.dart';

class StoreCategoryCirclesList extends StatelessWidget {
  const StoreCategoryCirclesList({super.key});

  static const List<String> _categories = [
    'Beauty',
    'Drink',
    'Meat',
    'Vegetables',
    'البقالة',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.viewStoreCategoryProductsScreen),
          child: SizedBox(
            width: 80,
            child: Column(
              spacing: 8,
              children: [
                const CircularBrandLogo(
                  radius: 40,
                  logoUrl:
                      'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                ),
                AutoSizeText(
                  _categories[index],
                  maxLines: 1,
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
