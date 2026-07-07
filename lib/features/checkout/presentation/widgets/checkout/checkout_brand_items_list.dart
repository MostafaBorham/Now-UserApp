
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card.dart';

import 'checkout_brand_item_card.dart';

class CheckoutBrandItemsList extends StatelessWidget {
  const CheckoutBrandItemsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: List.generate(4, (index) => CheckoutBrandItemCard()),
    );
  }
}