import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';

/// The standard answer to a cart update that just succeeded: a toast that
/// matches what actually changed — the line was added to, reduced, or removed.
///
/// Every screen that changes a cart line routes its success here, so the
/// wording cannot drift apart between screens.
void showCartUpdateFeedback(
  BuildContext context,
  WidgetRef ref, {
  required int productId,
  int? laneId,
  required CartModel cart,
}) {
  // Only the screen on top answers. A card on a covered screen — the listing
  // the product page was opened from — hears the same response, and claiming
  // it first would silence the screen the shopper is actually on.
  if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

  // The lane is the notifier that ran the update — a cart line keys it by its
  // `cart_item_id`, everything else by the product id ([laneId] omitted).
  final UpdateCartProductViewModel vm = ref.read(
    updateCartProductProvider(laneId ?? productId).notifier,
  );

  // Another card showing this product has already answered this response.
  if (!vm.claimFeedback()) return;

  // Both quantities are the product's total across its variant lines, so the
  // wording follows what changed even with several lines.
  AppToast.showSuccess(
    context,
    cartUpdateMessageKey(
      previousQuantity: vm.previousQuantity,
      quantity: cart.quantityOf(productId),
    ).tr(),
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

/// The message for a settled update, chosen by which way the line moved:
/// [previousQuantity] is the quantity before the request, [quantity] the one
/// the fresh cart reports.
///
/// Anything that is not a drop reads as an add, so a first add and a quantity
/// the server left untouched both confirm rather than claim a change that
/// didn't happen.
String cartUpdateMessageKey({
  required int previousQuantity,
  required int quantity,
}) {
  if (quantity < 1) return LangKeys.productRemovedFromCartKey;
  if (quantity < previousQuantity) return LangKeys.cartQuantityUpdatedKey;
  return LangKeys.productAddedToCartKey;
}
