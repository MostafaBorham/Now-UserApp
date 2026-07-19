import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart_product_item_view.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

import 'store_invoice_summary_card.dart';

class CartBrandItemDetailsView extends StatelessWidget {
  const CartBrandItemDetailsView({
    super.key,
    this.products,
    this.pricing,
    this.vendorName,
  });

  /// Cart lines rendered in the expanded card. Falls back to the static
  /// 3-item placeholder list when null.
  final List<ProductModel>? products;

  /// Vendor pricing breakdown for the invoice summary.
  final CartVendorPricingModel? pricing;

  /// Localized vendor name (API translation map) shown under each product.
  final Map<String, dynamic>? vendorName;

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
            return CartProductItemView(
              product: products?.elementAtOrNull(index),
              vendorName: vendorName,
            );
          },
          separatorBuilder: (context, index) => 16.hSpace,
          itemCount: products?.length ?? 3,
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
