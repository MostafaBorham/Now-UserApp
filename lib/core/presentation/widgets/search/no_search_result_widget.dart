import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NoSearchResultWidget extends StatelessWidget {
  const NoSearchResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      children: [
        Assets.media.images.svg.noSearchResultIcon.svg(),
        Text('No Result Found',style: AppTextStyles.style24SemiBold.copyWith(
          color: colors.black
        ),)
      ],
    );
  }
}