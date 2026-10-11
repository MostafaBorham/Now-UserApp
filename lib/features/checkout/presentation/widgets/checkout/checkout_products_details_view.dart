import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_product_item_view.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

class CheckoutProductsDetailsView extends StatelessWidget {
  const CheckoutProductsDetailsView({super.key, this.order});

  /// Draft order whose items and pricing drive the expanded card.
  final OrderModel? order;

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> items =
        order?.items ?? const <ProductModel>[];
    return ListView.separated(
      // A null padding takes the screen's safe-area insets — a gesture-bar
      // sized gap under the items inside this card (BUG-038).
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return CheckoutProductItemView(item: items[index]);
      },
      separatorBuilder: (context, index) => 16.hSpace,
      itemCount: items.length,
    );
  }
}
