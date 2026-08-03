import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_product_item_view.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

import '../../../../../core/presentation/widgets/store_invoice_summary_card.dart';

class CheckoutProductsDetailsView extends StatelessWidget {
  const CheckoutProductsDetailsView({super.key, this.order});

  /// Draft order whose items and pricing drive the expanded card.
  final OrderModel? order;

  @override
  Widget build(BuildContext context) {
    final List<OrderItemModel> items =
        order?.items ?? const <OrderItemModel>[];
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return CheckoutProductItemView(item: items[index]);
          },
          separatorBuilder: (context, index) => 16.hSpace,
          itemCount: items.length,
        ),

        // Store invoice summary
        StoreInvoiceSummaryCard(
          subtotal: order?.subtotal,
          tax: order?.tax,
          deliveryFee: order?.deliveryFee,
          discount: order?.discount,
        ),
      ],
    );
  }
}
