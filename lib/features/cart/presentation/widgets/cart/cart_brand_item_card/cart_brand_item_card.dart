import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_images_list_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart_brand_item_details_view.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/widgets/cart_item_checkout_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/expansions/logo_title_expansion_header.dart';

class CartBrandItemCard extends StatefulWidget {
  const CartBrandItemCard({super.key, this.readyToCheckout = false});
  final bool? readyToCheckout;
  @override
  State<CartBrandItemCard> createState() => _CartBrandItemCardState();
}

class _CartBrandItemCardState extends State<CartBrandItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            LogoTitleExpansionHeader(
              isExpanded: _isExpanded,
              onToggle: (bool expanded) =>
                  setState(() => _isExpanded = expanded),
            ),

             _isExpanded? CartBrandItemDetailsView() : StoreImagesListView(),

            // Total + checkout pill (shared between both states)
            CartItemCheckoutView(),
          ],
        ),
      ),
    );
  }
}