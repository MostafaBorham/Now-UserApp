import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../assets/assets.gen.dart';
import '../../styles/text_styles.dart';

class PriceWithCurrency extends StatelessWidget {
  const PriceWithCurrency({
    super.key,
    required this.color, required this.price,
  });

  final Color color;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        AutoSizeText(price,style: AppTextStyles.style14SemiBold.copyWith(
            color: color
        ),),
        Assets.media.images.svg.realSaudiCurrency.svg(
          width: 12.sp,
          height: 12.sp,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ],
    );
  }
}