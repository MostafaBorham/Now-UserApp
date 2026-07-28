import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Quantity pill: increment, the current [counter], and either decrement or
/// delete depending on how many units are in the cart.
///
/// While [isLoading] is true a quantity request is in flight: the number is
/// replaced by a spinner and the three icons stop responding, so the pill stays
/// on screen showing the last confirmed quantity until the request settles.
class AnimatedCartCounterView extends StatelessWidget {
  const AnimatedCartCounterView({
    super.key,
    required this.counter,
    this.isLoading = false,
    this.onInc,
    this.onDec,
    this.onDelete,
  });

  final int counter;
  final bool isLoading;
  final VoidCallback? onInc;
  final VoidCallback? onDec;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    // The pill usually sits inside a tappable product card, so it swallows every
    // tap that lands on it — on the number, the spinner or the padding around
    // them — instead of letting it bubble up and open the product details. The
    // icons keep working: the innermost recognizer still wins the gesture arena.
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
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
              onTap: isLoading ? null : onInc,
              child: Assets.media.images.png.increamentIcon.image(
                width: 15,
                color: colors.onPrimary,
              ),
            ),
            isLoading
                ? SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : AutoSizeText(
                    counter.toString(),
                    style: AppTextStyles.style12Medium.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
            counter < 2
                ? InkWell(
                    onTap: isLoading ? null : onDelete,
                    child: Assets.media.images.png.removeIcon.image(
                      width: 15,
                      color: colors.onPrimary,
                    ),
                  )
                : InkWell(
                    onTap: isLoading ? null : onDec,
                    child: Assets.media.images.png.decrementIcon.image(
                      width: 15,
                      color: colors.onPrimary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
