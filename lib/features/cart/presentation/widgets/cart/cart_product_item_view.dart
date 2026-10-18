import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_variant_pills.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart_update_feedback.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';

/// One cart line inside an expanded store card: the product, its price, the
/// quantity stepper and a delete button.
class CartProductItemView extends ConsumerStatefulWidget {
  const CartProductItemView({super.key, required this.product, this.stockFix});

  /// The cart line this row renders. Cart lines carry the product id in
  /// `product_id`, which is what the update requests are keyed by.
  final ProductModel product;

  /// What this line must drop to for the stock that is left (see
  /// [CartVendorModel.stockFixes]); `null` when it fits, `0` when it must go.
  final int? stockFix;

  @override
  ConsumerState<CartProductItemView> createState() =>
      _CartProductItemViewState();
}

class _CartProductItemViewState extends ConsumerState<CartProductItemView> {
  /// The quantity the server last confirmed for this line.
  ///
  /// Read straight off the line rather than mirrored into local state: the
  /// stepper never moves on its own — it only ever shows what the fresh cart
  /// reports — so there is nothing local to keep in sync, and nothing to
  /// revert when a request fails.
  int get _quantity => widget.product.quantity ?? 1;

  /// The smallest this line may go before removing it is the only way down —
  /// the store's minimum order quantity, or a single unit when it has none.
  int get _minQuantity => widget.product.minOrderQuantity ?? 1;

  /// Whether there is stock left to add. A `null` stock leaves it uncapped,
  /// same rule as [AnimatedCartButton] on the listing cards — the cart used to
  /// be the one place with no cap at all, so a line could be pushed past what
  /// the shop actually has.
  bool get _canIncrement {
    final int? stock = widget.product.stock;
    return stock == null || _quantity < stock;
  }

  /// The id the update requests are keyed by.
  ///
  /// Cart lines carry it in `product_id`, but a line that came back without one
  /// still has `id` — the same fallback [CartModel.lineOf] makes. Keying off
  /// `product_id` alone left the whole stepper inert on such a line, with no
  /// sign to the shopper that their taps were going nowhere.
  int? get _productId => widget.product.productId ?? widget.product.id;

  /// The lane the update requests key on. A cart line uses its `cart_item_id`,
  /// so two variants of one product get their own spinner and feedback instead
  /// of sharing the product's; a line without one falls back to the product id.
  int? get _laneId => widget.product.cartItemId ?? _productId;

  void _updateQuantity(int newQuantity) {
    final int? productId = _productId;
    final int? laneId = _laneId;
    if (productId == null || laneId == null) return;

    ref
        .read(updateCartProductProvider(laneId).notifier)
        .updateCartProductQuantity(
          newQuantity,
          productId: productId,
          cartItemId: widget.product.cartItemId,
          seededQuantity: _quantity,
        );
  }

  /// Asks before removing the line — as destructive as emptying a whole store,
  /// which has always confirmed.
  void _confirmRemove() {
    AppCustomAlertDialog.show(
      context,
      (BuildContext dialogContext) => AppCustomAlertDialog(
        title: LangKeys.removeProductKey.tr(),
        message: LangKeys.removeProductConfirmationKey.tr(
          namedArgs: <String, String>{
            'name': context.getLocalizedApiText(widget.product.name),
          },
        ),
        confirmLabel: LangKeys.deleteKey.tr(),
        onConfirm: () {
          dialogContext.pop();
          _updateQuantity(0);
        },
      ),
    );
  }

  void _handleUpdateResult(AsyncValue<CartModel?> state) {
    state.whenOrNull(
      data: (CartModel? cart) {
        if (cart == null) return;
        // The VM already pushed the fresh cart into getCartProvider; all that is
        // left is telling the shopper the change landed.
        final int? productId = _productId;
        if (productId == null || !mounted) return;

        showCartUpdateFeedback(
          context,
          ref,
          productId: productId,
          laneId: _laneId,
          cart: cart,
        );
      },
      error: (Object error, StackTrace _) {
        if (!mounted) return;
        // Nothing to undo: the stepper only ever showed the confirmed
        // quantity, which this failure left untouched.
        AppToast.showError(context, error.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ProductModel product = widget.product;

    final int? laneId = _laneId;
    bool isUpdating = false;
    if (laneId != null) {
      ref.listen<AsyncValue<CartModel?>>(
        updateCartProductProvider(laneId),
        (AsyncValue<CartModel?>? previous, AsyncValue<CartModel?> next) =>
            _handleUpdateResult(next),
      );
      isUpdating = ref.watch(updateCartProductProvider(laneId)).isLoading;
    }

    final int quantity = _quantity;
    final int? stockFix = widget.stockFix;
    // Over stock, every step but the last one down is refused by the server,
    // so the stepper waits and the reset (or delete) button does the fixing.
    final bool canIncrement = stockFix == null && _canIncrement;
    final bool canDecrement = stockFix == null && quantity > _minQuantity;

    final Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.productDetailsScreen,
            extra: product.slug,
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
              imageUrl: product.images?.firstOrNull ?? '',
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.getLocalizedApiText(product.name),
                      maxLines: 1,
                      style: AppTextStyles.style16Medium.copyWith(
                        color: colors.tertiaryContainer,
                      ),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: isUpdating,
                    child: Semantics(
                      button: true,
                      label: LangKeys.removeProductKey.tr(),
                      child: InkWell(
                        onTap: _confirmRemove,
                        child: Container(
                          height: 30,
                          width: 30,
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
                    ),
                  ),
                ],
              ),
              CartVariantPills(options: product.options),
              const SizedBox(height: 20),
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
                          price: formatMoney(
                            product.discountPrice ?? product.price,
                          ),
                          size: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        if (product.hasDeal)
                          OldPriceWidget(
                            color: colors.neutral500,
                            price: formatMoney(product.price),
                            size: 12,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: isUpdating,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: canIncrement
                                ? () => _updateQuantity(quantity + 1)
                                : null,
                            customBorder: const CircleBorder(),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: colors.black.withValues(
                                  alpha: canIncrement ? 1 : 0.3,
                                ),
                              ),
                            ),
                          ),
                          Center(
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
                                    quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.style16Medium.copyWith(
                                      color: colors.tertiaryContainer,
                                    ),
                                  ),
                          ),
                          // At the store's minimum the − goes inert; removing
                          // the line is the delete button's job.
                          InkWell(
                            onTap: canDecrement
                                ? () => _updateQuantity(quantity - 1)
                                : null,
                            customBorder: const CircleBorder(),
                            child: Container(
                              height: 30,
                              width: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 18,
                                color: colors.neutral500.withValues(
                                  alpha: canDecrement ? 1 : 0.3,
                                ),
                              ),
                            ),
                          ),
                          // Sets this line alone. On a product split over
                          // variant lines the server refuses it while a
                          // sibling marked "remove" still holds the stock, and
                          // its toast says so; the checkout sheet sends the
                          // removals first and gets past that.
                          if (stockFix != null && stockFix > 0)
                            Semantics(
                              button: true,
                              label: LangKeys.quantityWillBeReducedToKey.tr(
                                namedArgs: <String, String>{
                                  'quantity': '$stockFix',
                                },
                              ),
                              child: InkWell(
                                onTap: () => _updateQuantity(stockFix),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                    color: colors.errorContainer,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (stockFix == null) return row;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        row,
        Text(
          stockFix == 0
              ? LangKeys.notAvailableRemoveItKey.tr()
              : LangKeys.onlyAvailableOfRequestedKey.tr(
                  namedArgs: <String, String>{
                    'available': '$stockFix',
                    'requested': '$quantity',
                  },
                ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.style12Medium.copyWith(
            color: colors.errorContainer,
          ),
        ),
      ],
    );
  }
}
