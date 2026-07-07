import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';

class CartBrandItemsList extends StatelessWidget {
  const CartBrandItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(3),
      itemBuilder: (context, index) {
        return AspectRatio(
            aspectRatio: 2,
            child: CartBrandItemCard());
      },
      separatorBuilder: (context, index) {
        return 20.hSpace;
      },
      itemCount: 5,
    );
  }
}
