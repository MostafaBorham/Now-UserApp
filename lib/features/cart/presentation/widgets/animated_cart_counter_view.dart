import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AnimatedCartCounterView extends StatelessWidget {
  const AnimatedCartCounterView({
    super.key,
    required this.counter,
    this.isLoading = false,
    this.canIncrement = true,
    this.onInc,
    this.onDec,
    this.onDelete,
  });

  final int counter;
  final bool isLoading;

  final bool canIncrement;
  final VoidCallback? onInc;
  final VoidCallback? onDec;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // Swallows taps that miss the three icons. The counter sits on top of a
    // product card whose own onTap opens product details, so without this a
    // near-miss navigates away mid-edit.
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.brCircular8,
          color: colors.primary500Main,
        ),
        child: Row(
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: isLoading ? null : onInc,
              child: Assets.media.images.png.increamentIcon.image(
                width: 15,
                color: colors.white.withValues(alpha: canIncrement ? 1 : 0.4),
              ),
            ),

            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isLoading ? 0 : 1,
                  child: AutoSizeText(
                    counter.toString(),
                    style: AppTextStyles.style12Medium.copyWith(
                      color: colors.white,
                    ),
                  ),
                ),
                SizedBox.square(
                  dimension: 15,
                  child: isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.white,
                        )
                      : null,
                ),
              ],
            ),
            counter < 2
                ? InkWell(
                    onTap: isLoading ? null : onDelete,
                    child: Assets.media.images.png.removeIcon.image(
                      width: 15,
                      color: colors.white,
                    ),
                  )
                : InkWell(
                    onTap: isLoading ? null : onDec,
                    child: Assets.media.images.png.decrementIcon.image(
                      width: 15,
                      color: colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
