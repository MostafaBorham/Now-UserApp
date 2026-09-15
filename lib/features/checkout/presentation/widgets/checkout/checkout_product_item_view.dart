import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';

class CheckoutProductItemView extends StatelessWidget {
  const CheckoutProductItemView({super.key, this.item});


  final ProductModel? item;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            boxShadow: AppBoxShadows.greyElevation3,
          ),
          child: AppCachedNetworkImage(
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            imageUrl: item?.images?.firstOrNull ?? '',
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text(
                context.getLocalizedApiText(item?.name),
                maxLines: 1,
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 6,
                      spacing: 6,
                      children: [
                        NewPriceWidget(
                          color: colors.black,
                          price:
                              '${formatDouble(item?.discountPrice ?? item?.price)}',
                          size: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        if (item?.discountPrice != null)
                          OldPriceWidget(
                            color: colors.neutral500,
                            price: '${formatDouble(item?.price)}',
                            size: 12,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'x${item?.quantity ?? 0}',
                    maxLines: 1,
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.neutral500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
