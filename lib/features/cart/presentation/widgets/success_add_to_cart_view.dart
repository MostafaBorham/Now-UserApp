import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/animated_success_badge.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';

/// The standard answer to a cart update that just succeeded: the confirmation
/// sheet the first time a product joins the cart, and after that a toast that
/// matches what actually changed — the line was added to, reduced, or removed.
///
/// Every screen that changes a cart line routes its success here, so the two
/// cases cannot drift apart again. The product's name and image are read off
/// the fresh [cart] line, so callers need nothing but the id.
/// [onContinueShopping] and [onViewCart] are forwarded to the sheet — only
/// screens that need to step back out of the way, or to land the shopper
/// somewhere other than a pushed cart screen, pass them.
void showCartUpdateFeedback(
  BuildContext context,
  WidgetRef ref, {
  required int productId,
  int? laneId,
  required CartModel cart,
  VoidCallback? onContinueShopping,
  VoidCallback? onViewCart,
}) {
  // The lane is the notifier that ran the update — a cart line keys it by its
  // `cart_item_id`, everything else by the product id ([laneId] omitted).
  final UpdateCartProductViewModel vm = ref.read(
    updateCartProductProvider(laneId ?? productId).notifier,
  );

  // Another card showing this product has already answered this response.
  if (!vm.claimFeedback()) return;

  if (!vm.joinedCart) {
    // ponytail: quantityOf/lineOf match the first line of a product, so when the
    // same product is in the cart as two variant lines this toast's wording can
    // read off the sibling line. The update/remove itself is correct (driven by
    // cart_item_id). Upgrade: cart_item_id-aware quantityOfItem/lineOfItem.
    AppToast.showSuccess(
      context,
      cartUpdateMessageKey(
        previousQuantity: vm.previousQuantity,
        quantity: cart.quantityOf(productId),
      ).tr(),
    );
    return;
  }

  final ProductModel? line = cart.lineOf(productId);

  showSuccessAddToCartSheet(
    context,
    productName: line == null ? '' : context.getLocalizedApiText(line.name),
    productImageUrl: line?.images?.firstOrNull ?? '',
    onContinueShopping: onContinueShopping,
    onViewCart: onViewCart ?? () => openMainCartTab(context, ref),
  );
}

/// Lands the shopper on the main shell's cart tab rather than pushing a cart
/// screen on top of wherever they were. Switches the tab first, then unwinds
/// the router back to the shell so the freshly selected tab is what shows.
void openMainCartTab(BuildContext context, WidgetRef ref) {
  ref.read(mainTabIndexProvider.notifier).state = 2;
  final GoRouter router = GoRouter.of(context);
  while (router.canPop()) {
    router.pop();
  }
}

/// The message for a settled update of a line that was already in the cart,
/// chosen by which way the line moved: [previousQuantity] is the quantity before
/// the request, [quantity] the one the fresh cart reports.
///
/// Anything that is not a drop reads as an add, so a quantity the server left
/// untouched still confirms rather than claiming a change that didn't happen.
String cartUpdateMessageKey({
  required int previousQuantity,
  required int quantity,
}) {
  if (quantity < 1) return LangKeys.productRemovedFromCartKey;
  if (quantity < previousQuantity) return LangKeys.cartQuantityUpdatedKey;
  return LangKeys.productAddedToCartKey;
}

/// Opens the confirmation sheet for a product that just landed in the cart.
///
/// Every "add to cart" action answers this way, so the sheet is configured in
/// one place. [onContinueShopping] runs after the sheet closes; the default —
/// staying put — suits any screen the shopper can keep browsing from, so only
/// screens that need to step back (product details) pass their own.
///
/// [onViewCart] decides where "view cart" lands; callers routed through
/// [showCartUpdateFeedback] default to the main shell's cart tab.
Future<void> showSuccessAddToCartSheet(
  BuildContext context, {
  required String productName,
  required String productImageUrl,
  VoidCallback? onContinueShopping,
  VoidCallback? onViewCart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext sheetContext) => SuccessAddToCartView(
      productName: productName,
      productImageUrl: productImageUrl,
      onViewCart: () {
        sheetContext.pop();
        onViewCart?.call();
      },
      onContinueShopping: () {
        sheetContext.pop();
        onContinueShopping?.call();
      },
    ),
  );
}

/// Bottom sheet confirming that a product just landed in the cart.
class SuccessAddToCartView extends StatelessWidget {
  const SuccessAddToCartView({
    super.key,
    required this.productName,
    required this.productImageUrl,
    this.onViewCart,
    this.onContinueShopping,
  });

  final String productName;
  final String productImageUrl;
  final GestureTapCallback? onViewCart;
  final GestureTapCallback? onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSuccessBadge(
                  imageUrl: productImageUrl,
                  label: productName,
                ),
                16.hSpace,
                Text(
                  LangKeys.inTheShoppingCartKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style20Bold.copyWith(
                    color: colors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.neutral200),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: PrimaryAppButton(
                    title: LangKeys.viewCartKey.tr(),
                    titleStyle: AppTextStyles.style16Medium,
                    onTap: onViewCart,
                  ),
                ),
                Expanded(
                  child: UnPrimaryAppButton(
                    title: LangKeys.continueShoppingKey.tr(),
                    titleStyle: AppTextStyles.style16Medium,
                    onTap: onContinueShopping,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
