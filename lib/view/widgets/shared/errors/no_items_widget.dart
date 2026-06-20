import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class NoItemsWidget extends StatelessWidget {
  const NoItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 25,
        children: [
          Assets.media.images.svg.noItemsIcon.svg(width: 300.w),
          AutoSizeText('No Items Found Yet',style: AppTextStyles.style24SemiBold.copyWith(
            color: colors.onSecondary
          ),)
        ],
      ),
    );
  }
}
