import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class OldPriceWidget extends StatelessWidget {
  const OldPriceWidget({super.key, required this.color, this.size, required this.price});
  final Color color;
  final String price;
  final double? size;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          spacing: 2,
          children: [
            Assets.media.images.svg.realSaudiCurrency.svg(
              width: size ?? 14,
              height: size ?? 14,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            AutoSizeText(
              price,
              style: AppTextStyles.style14Medium.copyWith(
                color: color,
                height: 1,
                fontSize: size,
              ),
            ),
          ],
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: _StrikeThroughPainter(color: colors.neutral400),
          ),
        ),
      ],
    );
  }
}






class _StrikeThroughPainter extends CustomPainter {
  const _StrikeThroughPainter({required this.color});

  final Color color;

  static const double _verticalInset = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height - _verticalInset),
      Offset(size.width, _verticalInset),
      paint,
    );
  }

  @override
  bool shouldRepaint(_StrikeThroughPainter oldDelegate) =>
      oldDelegate.color != color;
}
