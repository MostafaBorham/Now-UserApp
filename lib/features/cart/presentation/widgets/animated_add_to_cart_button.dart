import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import '../../../../core/presentation/widgets/reverse_widget.dart';

class AnimatedAddToCartButton extends StatelessWidget {
  const AnimatedAddToCartButton({super.key, this.onEnd, this.isRotate = false, this.text = '+'});

  final VoidCallback? onEnd;
  final bool? isRotate;
  final String? text;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ReverseWidget(
          applyReverse: !context.isRTL,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            onEnd: onEnd,
            curve: Curves.easeInOut,
            turns: isRotate!? -0.125 : 0,
            child: Assets.media.images.svg.emptyAddToCart.svg(
              width: MediaQuery.sizeOf(context).width*0.075
            ),
          ),
        ),
        AutoSizeText(
          '$text',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: AppTextStyles.style12SemiBold.copyWith(
            color: colors.white,
            fontSize: MediaQuery.sizeOf(context).width*0.045
          ),
        ),
      ],
    );
  }
}
