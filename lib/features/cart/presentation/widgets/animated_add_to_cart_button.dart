import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

/// The round add-to-cart affordance on a product card: a cart glyph that tilts
/// when tapped, with the current quantity — or `+` — sitting on top of it.
///
/// [onEnd] fires when the tilt finishes, which is what [AnimatedCartButton]
/// waits for before opening its counter.
class AnimatedAddToCartButton extends StatelessWidget {
  const AnimatedAddToCartButton({
    super.key,
    this.onEnd,
    this.isRotate = false,
    this.text = '+',
  });

  final VoidCallback? onEnd;
  final bool isRotate;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double width = MediaQuery.sizeOf(context).width;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ReverseWidget(
          applyReverse: !context.isRTL,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            onEnd: onEnd,
            curve: Curves.easeInOut,
            turns: isRotate ? -0.125 : 0,
            child: Assets.media.images.svg.emptyAddToCart.svg(
              width: width * 0.075,
            ),
          ),
        ),
        // No explicit textDirection: this is a counter, and forcing RTL on it
        // did nothing for digits while being wrong for anything else.
        AutoSizeText(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.style12SemiBold.copyWith(
            color: colors.white,
            fontSize: width * 0.045,
          ),
        ),
      ],
    );
  }
}
