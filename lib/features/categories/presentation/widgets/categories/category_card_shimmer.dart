import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';



class CategoryCardShimmer extends StatelessWidget {
  const CategoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 6,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: AppBorderRadius.brCircular10,
            ),
          ),
        ),

        const SizedBox(height: 36),
      ],
    );
  }
}
