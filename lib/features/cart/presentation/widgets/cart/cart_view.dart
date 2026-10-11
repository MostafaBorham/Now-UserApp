import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_empty_view.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load the cart the first time it's opened (or retry a failed load);
    // otherwise refresh it quietly, so a deal that ended, a store that closed or
    // an edit from another device shows up without a manual pull.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final GetCartViewModel cartVm = ref.read(getCartProvider.notifier);
      ref.read(getCartProvider).hasValue ? cartVm.refresh() : cartVm.getCart();
    });
  }

  /// Pull-to-refresh: the loaded cart stays on screen, and a failure says so.
  Future<void> _onRefresh() async {
    final String? error = await ref.read(getCartProvider.notifier).refresh();
    // failure.message is a LangKeys key or a raw server string; .tr() localizes
    // the key case and passes a server string through unchanged.
    if (error != null && mounted) AppToast.showError(context, error.tr());
  }

  /// Drafts an order group and, only if the server accepted it, opens the
  /// checkout screen.
  ///
  /// [vendorId] `null` checks out every store via the all-stores
  /// `checkout/cart/preview` endpoint (bottom button); a concrete id checks out
  /// that single store via the dedicated `checkout/vendor/{id}/preview` endpoint
  /// (its own pill). On failure the reason is shown in a toast.
  Future<void> _checkout({int? vendorId}) async {
    // Guests are bounced before the draft is drafted. The `checkout` route is
    // login-gated, but drafting first and pushing only on success means a guest
    // never reaches that redirect — the request just fails with a toast.
    if (redirectGuestToLogin(context)) return;

    final CheckoutViewModel checkoutVm = ref.read(checkoutProvider.notifier);

    // Priced for the address checkout opens on (the default one), so the
    // delivery fee is the one the order will be charged.
    final String? error = await checkoutVm.checkout(
      vendorId: vendorId,
      addressId: ref.read(defaultAddressProvider).valueOrNull?.id,
    );

    if (!mounted) return;

    if (error != null) {
      AppToast.showError(context, error.tr());
      return;
    }

    // The cart is left alone here: drafting isn't placing. It's emptied on the
    // checkout screen, once the order is actually confirmed.

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
        scrollController: _scrollController,
        body: cartState.when(
          loading: () => CartShimmerView(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString().tr(),
                onRetry: () => ref.read(getCartProvider.notifier).getCart(),
              ),
          data: (CartModel cart) {
            // A vendor with no store (null id) can't be rendered or checked
            // out on its own, so it is dropped from the list entirely.
            final List<CartVendorModel> vendors = cart.vendors
                .where((CartVendorModel v) => v.vendor.id != null)
                .toList();

            // Checking out every store at once only works if every one of them
            // is checkoutable — one store under its minimum fails the whole
            // draft server-side, so the button says so up front instead of
            // spending a request to find out.
            final bool canCheckoutAll = vendors.every(
              (CartVendorModel v) =>
                  v.pricing.available && v.pricing.minOrderMet,
            );

            return AppRefreshIndicator(
              onRefresh: _onRefresh,
              child: vendors.isEmpty
                  ? const CartEmptyView()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,
                            // Always scrollable so pull-to-refresh fires even
                            // when a single item doesn't fill the viewport;
                            // otherwise the list can't overscroll and the
                            // gesture never reaches the refresh indicator.
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Owns the top spacing AppWavedView drops when a
                            // scroll controller is wired in, so it scrolls up
                            // with the content and flattens the wave.
                            padding: const EdgeInsets.fromLTRB(3, 57, 3, 20),
                            itemBuilder: (context, index) {
                              final CartVendorModel cartVendor = vendors[index];

                              return CartBrandItemCard(
                                // The card owns its expanded/collapsed state,
                                // so it has to be identified by store rather
                                // than by position — otherwise removing a
                                // store above an expanded one hands that
                                // expansion to whichever store slides up into
                                // its index.
                                key: ValueKey<int>(cartVendor.vendor.id!),
                                cartVendor: cartVendor,
                                // One store: the footer button checks it
                                // out, so a second button is just noise.
                                onCheckout: vendors.length == 1
                                    ? null
                                    : () => _checkout(
                                        vendorId: cartVendor.vendor.id!,
                                      ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return 20.hSpace;
                            },
                            itemCount: vendors.length,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.paddingOf(context).bottom,
                          ),
                          child: PrimaryAppButton(
                            title: LangKeys.checkoutKey.tr(),
                            isDisabled: !canCheckoutAll,
                            onTap: () => _checkout(),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
