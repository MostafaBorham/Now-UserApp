import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

class StoreInfoRow extends StatelessWidget {
  const StoreInfoRow({
    super.key, required this.infoFontSize, required this.infoIconSize,
    this.deliveryTime, this.distance, this.deliveryFee,
  });
  final double infoFontSize;
  final double infoIconSize;
  final int? deliveryTime;
  final double? distance;
  final double? deliveryFee;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Assets.media.images.svg.timeIcon.svg(
          width: infoIconSize,
          colorFilter: ColorFilter.mode(
            colors.onSurface,
            BlendMode.srcIn,
          ),
        ),
        Text(
          '${deliveryTime ?? 0} minutes',
          style: AppTextStyles.style12Medium.copyWith(
              color: colors.onSecondary,
              fontSize: infoFontSize
          ),
        ),
        5.wSpace,
        Assets.media.images.svg.locationIcon.svg(
          width: infoIconSize,
          colorFilter: ColorFilter.mode(
            colors.onSurface,
            BlendMode.srcIn,
          ),
        ),
        Text(
          '${distance ?? 0} km',
          style: AppTextStyles.style12Medium.copyWith(
              color: colors.onSecondary,
              fontSize: infoFontSize
          ),
        ),
        5.wSpace,
        Assets.media.images.svg.shippingIcon.svg(
          width: infoIconSize,
          colorFilter: ColorFilter.mode(
            colors.onSurface,
            BlendMode.srcIn,
          ),
        ),
        NewPriceWidget(
          color: colors.onSecondary,
          price: '${deliveryFee ?? 0}',
          size: infoFontSize,
        ),
      ],
    );
  }
}
