import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_products_images_list_view.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_details_view.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/widgets/cart_item_checkout_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/expansions/logo_title_expansion_header.dart';

class CartBrandItemCard extends StatefulWidget {
  const CartBrandItemCard({
    super.key,
    required this.cartVendor,
    this.onCheckout,
  });

  final CartVendorModel cartVendor;

  /// Fired when this store's checkout pill is tapped. `null` leaves the pill
  /// inert — the parent owns both the request and the navigation.
  final VoidCallback? onCheckout;

  @override
  State<CartBrandItemCard> createState() => _CartBrandItemCardState();
}

class _CartBrandItemCardState extends State<CartBrandItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final CartVendorPricingModel pricing = widget.cartVendor.pricing;
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
              storeName: widget.cartVendor.vendor.name,
              logoUrl: widget.cartVendor.vendor.logoUrl,
            ),

            _isExpanded
                ? CartBrandItemDetailsView(
                    products: widget.cartVendor.products,
                    pricing: pricing,
                    store: widget.cartVendor.vendor,
                  )
                : CartProductsImagesListView(
                    products: widget.cartVendor.products,
                    storeId: widget.cartVendor.vendor.id,
                    storeName: widget.cartVendor.vendor.name,
                  ),

            // Total + checkout pill (shared between both states)
            CartItemCheckoutView(
              pricing: pricing,
              onCheckout: widget.onCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
