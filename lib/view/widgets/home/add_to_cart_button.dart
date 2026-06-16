import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../assets/assets.gen.dart';
import '../../styles/text_styles.dart';
import '../shared/reverse_widget.dart';

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({super.key, this.onEnd, this.isRotate = false, this.text = '+'});

  final VoidCallback? onEnd;
  final bool? isRotate;
  final String? text;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        ReverseWidget(
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            onEnd: onEnd,
            curve: Curves.easeInOut,
            turns: isRotate!? -0.125 : 0,
            child: Assets.media.images.svg.emptyAddToCart.svg(),
          ),
        ),
        AutoSizeText(
          '$text',
          textAlign: TextAlign.center,
          style: AppTextStyles.style18Bold.copyWith(
            color: colors.onPrimary,
          ),
        ),
      ],
    );
  }
}
