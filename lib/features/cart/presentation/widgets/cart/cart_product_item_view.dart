import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/delete_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

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
    this.onDelete,
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
  final VoidCallback? onDelete;
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
        // The VM already pushed the fresh cart into getCartProvider.
      },
      error: (Object error, StackTrace _) {
        if (!mounted) return;
        setState(
          () => _quantity = widget.product?.quantity ?? widget.initialQuantity,
        );

        final ColorScheme colors = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                error.toString().tr(),
                style: AppTextStyles.style16SemiBold.copyWith(
                  color: colors.onPrimary,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.onError,
            ),
          );
      },
    );
  }

  /// Asks the user to confirm removing this line, then runs the deletion inside
  /// the dialog: on success the dialog closes and the fresh cart is pushed into
  /// [getCartProvider] (no refetch), on failure it stays open with an error
  /// snackbar. The dialog watches [deleteCartProductProvider] itself, so the
  /// spinner and the disabled buttons follow the request automatically.
  void _showDeleteDialog(String productName) {
    final int? productId = widget.product?.productId;
    if (productId == null) return;

    AppCustomAlertDialog.show(
      context,
      (_) => Consumer(
        builder: (BuildContext dialogContext, WidgetRef dialogRef, Widget? _) {
          dialogRef.listen<AsyncValue<CartModel?>>(
            deleteCartProductProvider(productId),
            (AsyncValue<CartModel?>? previous, AsyncValue<CartModel?> next) {
              next.whenOrNull(
                data: (CartModel? cart) {
                  if (cart == null) return;
                  Navigator.of(dialogContext).pop();
                  ref.read(getCartProvider.notifier).updateCartState(cart);
                },
                error: (Object error, StackTrace _) =>
                    ErrorSnackBar.show(dialogContext, error.toString()),
              );
            },
          );

          return AppCustomAlertDialog(
            title: LangKeys.removeProductKey.tr(),
            message: LangKeys.removeProductConfirmationKey.tr(
              namedArgs: <String, String>{'name': productName},
            ),
            confirmLabel: LangKeys.deleteKey.tr(),
            isLoading: dialogRef
                .watch(deleteCartProductProvider(productId))
                .isLoading,
            onConfirm: () => dialogRef
                .read(deleteCartProductProvider(productId).notifier)
                .deleteCartProduct(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
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
    final String storeName = widget.vendorName != null
        ? context.getLocalizedApiText(widget.vendorName)
        : widget.storeName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.productDetailsScreen,
            extra: product?.slug,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 76,
              height: 76,
              child: AppCachedNetworkImage(
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                imageUrl: widget.product?.images?.firstOrNull ?? '',
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      maxLines: 1,
                      style: AppTextStyles.style16Medium.copyWith(
                        color: colors.tertiaryContainer,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showDeleteDialog(productName),
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Assets.media.images.svg.deleteIcon.svg(
                        colorFilter: ColorFilter.mode(
                          colors.onError,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    spacing: 4,
                    children: [
                      if ((widget.product?.comparePrice ?? 0) > 0)
                        OldPriceWidget(
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
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colors.onPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: colors.onSecondary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Center(
                            child: isUpdating
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onSecondary,
                                    ),
                                  )
                                : Text(
                                    _quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.style14Medium.copyWith(
                                      color: colors.tertiaryContainer,
                                    ),
                                  ),
                          ),
                        ),
                        InkWell(
                          onTap: _quantity > 1
                              ? () => _updateQuantity(_quantity - 1)
                              : null,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colors.onPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 16,
                              color: colors.onSurface,
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
