import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class StoreInfoRow extends StatelessWidget {
  const StoreInfoRow({
    super.key, required this.infoFontSize, required this.infoIconSize,
    this.deliveryTime, this.distance, this.deliveryFee, this.color,
  });
  final double infoFontSize;
  final double infoIconSize;
  final String? deliveryTime;
  final String? distance;
  final String? deliveryFee;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color iconColor = color ?? colors.neutral500;
    final Color textColor = color ?? colors.black;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Assets.media.images.svg.timeIcon.svg(
          width: infoIconSize,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
        ),
        Text(
          '${deliveryTime ?? 0}',
          style: AppTextStyles.style12Medium.copyWith(
              color: textColor,
              fontSize: infoFontSize
          ),
        ),
        5.wSpace,
        Assets.media.images.svg.locationIcon.svg(
          width: infoIconSize,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
        ),
        Text(
          distance ?? '0',
          style: AppTextStyles.style12Medium.copyWith(
              color: textColor,
              fontSize: infoFontSize
          ),
        ),
        5.wSpace,
        ReverseWidget(
          child: Assets.media.images.svg.shippingIcon.svg(
            width: infoIconSize,
            colorFilter: ColorFilter.mode(
              iconColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        NewPriceWidget(
          color: textColor,
          price: deliveryFee ?? '0',
          size: infoFontSize,
        ),
      ],
    );
  }
}
