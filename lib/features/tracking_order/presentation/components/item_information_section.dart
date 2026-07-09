import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';

import 'tracking_section_card.dart';

/// "Item Information" section: the ordered product with its price and quantity.
class ItemInformationSection extends StatelessWidget {
  const ItemInformationSection({
    super.key,
    this.name = 'Almarai Milk 2 Liters',
    this.price = '20.00',
    this.quantity = 1,
  });

  final String name;
  final String price;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return TrackingSectionCard(
      title: LangKeys.itemInformationKey.tr(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TrackingOrderColors.itemImagePlaceholder,
              borderRadius: AppBorderRadius.brCircular12,
            ),
          ),
          12.wSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  style: AppTextStyles.style16Medium.copyWith(
                    color: colors.onSecondary,
                  ),
                ),
                6.hSpace,
                Row(
                  children: [
                    Assets.media.images.svg.realSaudiCurrency.svg(
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        colors.onSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    5.wSpace,
                    Text(
                      price,
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          12.wSpace,
          Text(
            'x$quantity',
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
