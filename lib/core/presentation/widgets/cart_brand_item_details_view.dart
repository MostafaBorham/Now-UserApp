import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart_product_item_view.dart';

import 'store_invoice_summary_card.dart';

class CartBrandItemDetailsView extends StatelessWidget {
  const CartBrandItemDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return CartProductItemView();
          },
          separatorBuilder: (context, index) => 16.hSpace,
          itemCount: 3,
        ),

          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: colors.onPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Assets.media.images.svg.circleAddMoreBrokenIcon
                      .svg(),
                  Text(
                    'Add More Items',
                    style: AppTextStyles.style14Medium.copyWith(
                      color: colors.onTertiaryFixed,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Store invoice summary
          StoreInvoiceSummaryCard(),

      ],
    );
  }
}
