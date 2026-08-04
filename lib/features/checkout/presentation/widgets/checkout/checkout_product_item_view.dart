import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

class CheckoutProductItemView extends StatelessWidget {
  const CheckoutProductItemView({super.key, this.item});

  /// Draft order line whose data drives this row.
  final ProductModel? item;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: SizedBox(
            width: 76,
            height: 76,
            child: AppCachedNetworkImage(
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              imageUrl: '',
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.getLocalizedApiText(item?.name),
                maxLines: 1,
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              Text(
                'x${item?.quantity ?? 0}',
                maxLines: 1,
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.neutral500,
                ),
              ),
              10.hSpace,
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.ltr,
                spacing: 4,
                children: [
                  NewPriceWidget(
                    color: colors.black,
                    price: '${item?.price ?? 0}',
                    size: 14,
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
