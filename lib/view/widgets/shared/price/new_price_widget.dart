import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../assets/assets.gen.dart';
import '../../../styles/text_styles.dart';
import '../price_cancel_line.dart';

class NewPriceWidget extends StatelessWidget {
  const NewPriceWidget({super.key, required this.color, this.size, required this.price});
  final Color color;
  final String price;
  final double? size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Row(
      textDirection: TextDirection.ltr,
      spacing: 5,
      mainAxisSize: .min,
      children: [
        Assets.media.images.svg.realSaudiCurrency.svg(
          width: size?? 20,
          height: size?? 20,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        AutoSizeText(price,style: AppTextStyles.style28SemiBold.copyWith(
          color: color,
          height: 1,
        ),),

      ],
    );
  }
}
