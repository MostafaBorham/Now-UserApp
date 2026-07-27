import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';

/// The cart screen's body.
///
/// Checking out is driven from here — both from a single store's pill and from
/// the bottom button — instead of from the checkout screen: the draft request
/// is fired first and the screen is pushed only once it succeeded, so checkout
/// never opens on a request that turns out to fail.
class CartView extends ConsumerStatefulWidget {
  const CartView({super.key, this.canPop});

  /// Whether the app bar shows a back arrow.
  ///
  /// Left `null` the view falls back to `context.canPop()`, which is right for
  /// the pushed [CartScreen]. The copy embedded in the main screen's tab bar
  /// must pass `false`: it shares the root navigator, so once checkout is
  /// pushed `context.canPop()` turns `true` for it too and any rebuild while
  /// checkout is open leaves a back arrow behind after popping back.
  final bool? canPop;

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView> {
  /// Drafts an order group and, only if the server accepted it, drops what was
  /// checked out from the cart and opens the checkout screen.
  ///
  /// [vendorId] `null` checks out every store (bottom button) and empties the
  /// cart; a concrete id checks out that single store (its own pill) and
  /// removes just that store. On failure the cart is left untouched and the
  /// reason is shown in a snackbar.
  Future<void> _checkout({int? vendorId}) async {
    final String? error = await ref
        .read(checkoutProvider.notifier)
        .checkout(vendorId: vendorId);

    if (!mounted) return;

    if (error != null) {
      ErrorSnackBar.show(context, error);
      return;
    }

    final GetCartViewModel cartNotifier = ref.read(getCartProvider.notifier);

    if (vendorId == null) {
      cartNotifier.clearVendors();
    } else {
      cartNotifier.removeVendor(vendorId);
    }

    // The id is forwarded so the checkout screen can re-fire the very same
    // request if the user retries after a later failure.
    context.pushNamed(AppRoutes.checkoutScreen, extra: vendorId);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CartModel> cartState = ref.watch(getCartProvider);

    // The draft request blocks the whole screen: no second checkout — of the
    // same store or of another one — may start while one is in flight.
    final bool isCheckingOut = ref.watch(
      checkoutProvider.select(
        (AsyncValue<CheckoutModel?> state) => state.isLoading,
      ),
    );

    return BlockingLoadingOverlay(
      isLoading: isCheckingOut,
      child: AppWavedView(
        appBarTitle: LangKeys.cartKey.tr(),
        canPop: widget.canPop,
        body: cartState.when(
          loading: () => CartShimmerView(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: () => ref.read(getCartProvider.notifier).getCart(),
              ),
          data: (CartModel cart) => AppRefreshIndicator(
            onRefresh: () async => ref.read(getCartProvider.notifier).getCart(),
            child: cart.vendors.isEmpty
                ? const NoItemsWidget(isScrollable: true)
                : Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(3),
                          itemBuilder: (context, index) {
                            final CartVendorModel cartVendor =
                                cart.vendors[index];
                            final int? vendorId = cartVendor.vendor.id;

                            return CartBrandItemCard(
                              cartVendor: cartVendor,
                              // A store with no id can't be drafted on its own:
                              // passing `null` down would check out the whole
                              // cart instead, so its pill stays inert.
                              onCheckout: vendorId == null
                                  ? null
                                  : () => _checkout(vendorId: vendorId),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return 20.hSpace;
                          },
                          itemCount: cart.vendors.length,
                        ),
                      ),
                      PrimaryAppButton(
                        title: LangKeys.checkoutKey.tr(),
                        onTap: () => _checkout(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
