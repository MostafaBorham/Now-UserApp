import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AnimatedCartCounterView extends StatelessWidget {
  const AnimatedCartCounterView({super.key, required this.counter, this.onInc, this.onDec, this.onDelete});
  final int counter;
  final VoidCallback? onInc;
  final VoidCallback? onDec;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.brCircular8,
        color: colors.primary,
      ),
      child: Row(
        spacing: 15,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap:onInc ,
            child: Assets.media.images.png.increamentIcon.image(
              width: 15,
              color: colors.onPrimary,
            ),
          ),
          AutoSizeText(
            counter.toString(),
            style: AppTextStyles.style12Medium.copyWith(
              color: colors.onPrimary,
            ),
          ),
          counter<2? InkWell(
            onTap: onDelete,
            child: Assets.media.images.png.removeIcon.image(
              width: 15,
              color: colors.onPrimary,
            ),
          ) : InkWell(
            onTap: onDec,
            child: Assets.media.images.png.decrementIcon.image(
              width: 15,
              color: colors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}