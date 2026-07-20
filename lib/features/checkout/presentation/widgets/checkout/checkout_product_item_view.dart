import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/delete_cart_product_dialog.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

class CheckoutProductItemView extends StatefulWidget {
  const CheckoutProductItemView({
    super.key,
    this.product,
    this.vendorName,
    this.productName = 'Almarai Milk 2 Liters',
    this.storeName = 'Panda Store',
    this.imageUrl =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
    this.oldPrice = '10',
    this.newPrice = '10',
    this.initialQuantity = 1,
    this.onDelete,
    this.onQuantityChanged,
  });

  /// Cart line whose data drives this row. When null, the [productName]/
  /// [storeName]/[imageUrl]/price placeholder values are shown instead.
  final ProductModel? product;

  /// Localized vendor name (API translation map) for the store label.
  final Map<String, dynamic>? vendorName;

  final String productName;
  final String storeName;
  final String imageUrl;
  final String oldPrice;
  final String newPrice;
  final int initialQuantity;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onQuantityChanged;

  @override
  State<CheckoutProductItemView> createState() => _CheckoutProductItemViewState();
}

class _CheckoutProductItemViewState extends State<CheckoutProductItemView> {
  late int _quantity = widget.product?.quantity ?? widget.initialQuantity;

  static String _money(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final ProductModel? product = widget.product;

    final String productName = product != null
        ? context.getLocalizedApiText(product.name)
        : widget.productName;
    final String storeName = widget.vendorName != null
        ? context.getLocalizedApiText(widget.vendorName)
        : widget.storeName;

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: product?.slug,
      ),
      child: Row(
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
                imageUrl: widget.product?.imageUrl??'',
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  style: AppTextStyles.style16Medium.copyWith(
                    color: colors.tertiaryContainer,
                  ),
                ),
                Text(
                  storeName,
                  maxLines: 1,
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                10.hSpace,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.ltr,
                  spacing: 4,
                  children: [
                    if((widget.product?.comparePrice ?? 0) > 0)OldPriceWidget(
                      color: colors.onSurface,
                      price: '${widget.product?.comparePrice}',
                      size: 10,
                    ),
                    NewPriceWidget(
                      color: colors.onSecondary,
                      price: '${widget.product?.price}',
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
