import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

import 'tracking_section_card.dart';

/// "Item Information" section: every product in the order with its thumbnail,
/// localized name, price and ordered quantity. A detail-page list, so all items
/// are shown in full rather than clamped to one.
class ItemInformationSection extends StatelessWidget {
  const ItemInformationSection({super.key, this.items = const <ProductModel>[]});

  final List<ProductModel> items;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return TrackingSectionCard(
      title: LangKeys.itemInformationKey.tr(),
      child: Column(
        spacing: 16,
        children: [
          for (final ProductModel item in items)
            Row(
              children: [
                ClipRRect(
                  borderRadius: AppBorderRadius.brCircular12,
                  child: AppCachedNetworkImage(
                    imageUrl: item.images?.firstOrNull ?? '',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                12.wSpace,
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.getLocalizedApiText(item.name),
                              overflow: TextOverflow.visible,
                              style: AppTextStyles.style16Medium.copyWith(
                                color: colors.black,
                              ),
                            ),
                            6.hSpace,
                            NewPriceWidget(
                              color: colors.black,
                              size: 14,
                              fontWeight: FontWeight.w400,
                              price: (item.price ?? 0).toStringAsFixed(2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'x${item.quantity ?? 0}',
                        style: AppTextStyles.style16Medium.copyWith(
                          color: colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
