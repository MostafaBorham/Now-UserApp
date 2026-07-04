import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import '../../../../../core/presentation/widgets/logos/circular_brand_logo.dart';

class CircularBrandItem extends StatelessWidget {
  const CircularBrandItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      spacing: 10,
      children: [
        CircularBrandLogo(radius: 50,logoUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',),
        AutoSizeText('Panda',style: AppTextStyles.style16SemiBold.copyWith(
          color: colors.onSecondary,
        ),),
      ],
    );
  }
}
