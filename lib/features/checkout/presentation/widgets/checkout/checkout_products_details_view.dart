import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_product_item_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_product_item_view.dart';

import '../../../../../core/presentation/widgets/store_invoice_summary_card.dart';

class CheckoutProductsDetailsView extends StatelessWidget {
  const CheckoutProductsDetailsView({
    super.key,
    this.products,
    this.pricing,
    this.store,
  });

  /// Cart lines rendered in the expanded card. Falls back to the static
  /// 3-item placeholder list when null.
  final List<ProductModel>? products;

  /// Vendor pricing breakdown for the invoice summary.
  final CartVendorPricingModel? pricing;

  /// Localized vendor name (API translation map) shown under each product.
  final StoreModel? store;

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
            return CheckoutProductItemView(
              product: products?.elementAtOrNull(index),
              vendorName: store?.name,
            );
          },
          separatorBuilder: (context, index) => 16.hSpace,
          itemCount: products?.length ?? 3,
        ),

        // Store invoice summary
        StoreInvoiceSummaryCard(pricing: pricing),
      ],
    );
  }
}
