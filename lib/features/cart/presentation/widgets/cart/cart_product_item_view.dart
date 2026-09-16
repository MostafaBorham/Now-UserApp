import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/success_add_to_cart_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';

class CartProductItemView extends ConsumerStatefulWidget {
  const CartProductItemView({
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
    // this.onQuantityChanged,
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
  // final ValueChanged<int>? onQuantityChanged;

  @override
  ConsumerState<CartProductItemView> createState() =>
      _CartProductItemViewState();
}

class _CartProductItemViewState extends ConsumerState<CartProductItemView> {
  late int _quantity = widget.product?.quantity ?? widget.initialQuantity;

  @override
  void didUpdateWidget(covariant CartProductItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the shared cart is refreshed (e.g. after a successful update) the
    // parent passes a new product; keep the displayed quantity in sync with
    // that server truth.
    final int? newQuantity = widget.product?.quantity;
    if (newQuantity != null && newQuantity != oldWidget.product?.quantity) {
      _quantity = newQuantity;
    }
  }

  /// Pushes [newQuantity] to the server for this cart line. The optimistic
  /// [_quantity] is already applied by the caller; a failure reverts it.
  void _updateQuantity(int newQuantity) {
    final int? productId = widget.product?.productId;
    if (productId == null) return;

    // setState(() => _quantity = newQuantity);
    // widget.onQuantityChanged?.call(newQuantity);

    ref
        .read(updateCartProductProvider(productId).notifier)
        .updateCartProductQuantity(newQuantity);
  }

  /// Applies the server result of a quantity update: refresh the shared cart on
  /// success, revert the optimistic quantity and surface the error otherwise.
  void _handleUpdateResult(AsyncValue<CartModel?> state) {
    state.whenOrNull(
      data: (CartModel? cart) {
        if (cart == null) return;
        // The VM already pushed the fresh cart into getCartProvider; all that is
        // left is telling the shopper the change landed.
        final int? productId = widget.product?.productId;
        if (productId == null || !mounted) return;

        showCartUpdateFeedback(context, ref, productId: productId, cart: cart);
      },
      error: (Object error, StackTrace _) {
        if (!mounted) return;
        setState(
          () => _quantity = widget.product?.quantity ?? widget.initialQuantity,
        );

        AppToast.showError(context, error.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ProductModel? product = widget.product;

    final int? productId = product?.productId;
    bool isUpdating = false;
    if (productId != null) {
      ref.listen<AsyncValue<CartModel?>>(
        updateCartProductProvider(productId),
        (AsyncValue<CartModel?>? previous, AsyncValue<CartModel?> next) =>
            _handleUpdateResult(next),
      );
      isUpdating = ref.watch(updateCartProductProvider(productId)).isLoading;
    }

    final String productName = product != null
        ? context.getLocalizedApiText(product.name)
        : widget.productName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.productDetailsScreen,
            extra: product?.slug,
          ),
          child: Container(
            width: 70,
            height: 70,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              boxShadow: AppBoxShadows.greyElevation3,
            ),
            child: AppCachedNetworkImage(
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              imageUrl: widget.product?.images?.firstOrNull ?? '',
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                productName,
                maxLines: 1,
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 6,
                      spacing: 6,
                      children: [
                        NewPriceWidget(
                          color: colors.black,
                          price: '${(widget.product?.discountPrice ?? 0) < 0
                              ? widget.product?.price
                              : widget.product?.discountPrice}',
                          size: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        if ((widget.product?.discountPrice ?? 0) > 0)
                          OldPriceWidget(
                            color: colors.neutral500,
                            price: '${formatDouble(widget.product?.price)}',
                            size: 12,
                          ),
                      ],
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: isUpdating,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        InkWell(
                          onTap: () => _updateQuantity(_quantity + 1),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 12,
                              color: colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: isUpdating
                                ? SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.black,
                                    ),
                                  )
                                : Text(
                                    _quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.style12Medium.copyWith(
                                      color: colors.tertiaryContainer,
                                    ),
                                  ),
                          ),
                        ),
                        // On the last unit there is nothing left to decrement,
                        // so the icon becomes the delete action — same rule as
                        // [AnimatedCartCounterView], where `0` removes the line.
                        InkWell(
                          onTap: () => _updateQuantity(
                            _quantity > 1 ? _quantity - 1 : 0,
                          ),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _quantity > 1
                                ? Icon(
                                    Icons.remove_rounded,
                                    size: 12,
                                    color: colors.neutral500,
                                  )
                                : Assets.media.images.png.removeIcon.image(
                                    width: 12,
                                    color: colors.errorContainer,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
