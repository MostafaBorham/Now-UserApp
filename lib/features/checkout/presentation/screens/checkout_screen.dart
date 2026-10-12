import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/driver_tip_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_brand_cards_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/confirm_order_button.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_address_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_instructions_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/invoice_summary_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/purchase_vouchers_strip.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/checkout_payment_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/wallet_payment_row.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/tip_your_driver_view.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/confirm_order_vm.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.storeId});

  /// `null` checks out every store in the cart; a concrete id checks out only
  /// that single store.
  final int? storeId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int? _addressId;

  // Holds the per-order delivery instructions the user types inline; read on
  // confirm and sent as the order `delivery_instructions`.
  final TextEditingController _instructionsController = TextEditingController();

  // The body's scroll view; handed to [AppWavedView] too, which then leaves
  // the top spacing to it.
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // The balance decides whether the wallet can pay, and it changes outside
    // the app (refunds, credits, the last order), so it is fetched fresh here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(getWalletInfoProvider.notifier).getWalletInfo();
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onConfirmOrder() {
    // Read from the async provider rather than [checkoutModelProvider]: the
    // latter only exists inside the scope below, which this `ref` is above.
    final CheckoutModel? checkout = ref.read(checkoutProvider).valueOrNull;

    if (checkout == null) return;

    // Block the order until a delivery address is resolved: with no default (or
    // chosen) address there's no id to send, so surface an error and stop here
    // instead of firing the request with a placeholder id.
    if (_addressId == null) {
      AppToast.showError(context, LangKeys.pleaseSelectAddressKey.tr());
      return;
    }

    // The wallet pays while its checkbox is ticked (see walletUseProvider for
    // the default). Untick it and the picked saved card pays: the backend
    // requires a `payment_method_id` for the `card` method and prohibits one
    // for wallet/cod, so the id rides along only in the card case. Selection
    // defaults to the preview's default card. There is no split payment: a
    // short wallet disables the button, and its note says why.
    final WalletUse walletUse = ref.read(walletUseProvider);
    final String paymentMethod;
    final int? paymentMethodId;
    if (walletUse == WalletUse.short) return;
    if (walletUse == WalletUse.pays) {
      paymentMethod = 'wallet';
      paymentMethodId = null;
    } else {
      final int? selectedCardId = ref.read(selectedPaymentCardProvider) ??
          CheckoutModel.resolveDefaultCard(checkout.paymentCards)?.id;
      if (selectedCardId == null) {
        // Only reachable with no usable card and the wallet unticked.
        AppToast.showError(context, LangKeys.addCardOrUseWalletKey.tr());
        return;
      }
      paymentMethod = 'card';
      paymentMethodId = selectedCardId;
    }

    ref
        .read(confirmOrderProvider.notifier)
        .confirmOrder(
          vendorId: widget.storeId,
          addressId: _addressId!,
          paymentMethod: paymentMethod,
          paymentMethodId: paymentMethodId,
          driverTip: ref.read(driverTipProvider),
          deliveryInstructions: _instructionsController.text.trim(),
          discounts: ref.read(appliedDiscountsProvider),
        );
  }

  /// Prices the order again with what the customer has chosen so far, so the
  /// invoice shows what placing it will charge.
  void _reprice() => ref
      .read(checkoutProvider.notifier)
      .reprice(
        addressId: _addressId,
        discounts: ref.read(appliedDiscountsProvider),
      );

  @override
  Widget build(BuildContext context) {
    // Nothing is `watch`ed here on purpose: this build must run once, or the
    // whole body would be rebuilt with it.

    // An applied or removed code changes the price. Listening also keeps the
    // `autoDispose` discounts alive for as long as the screen is.
    ref.listen<List<AppliedDiscountModel>>(
      appliedDiscountsProvider,
      (_, _) => _reprice(),
    );

    // Keeps the autoDispose tip alive for as long as the screen is, so confirm
    // sends the tip the invoice shows.
    ref.listen<double>(driverTipProvider, (_, _) {});

    // A failed re-price keeps the page (see the builder below), so say so:
    // the totals on it may no longer match the choices above them.
    ref.listen<AsyncValue<CheckoutModel?>>(checkoutProvider, (_, next) {
      if (!next.isLoading && next.hasError && next.hasValue) {
        // failure.message is a LangKeys key or a raw server string; .tr()
        // localizes the key case and passes a server string through unchanged.
        AppToast.showError(
          context,
          next.error.toString().tr(),
          title: LangKeys.pricesNotUpdatedTitleKey.tr(),
        );
      }
    });

    // React to the outcome of a confirm-order request: on success push the
    // confirmation screen, on failure surface the message via the shared
    // error snackbar. Uses `listen` (not `watch`) so this fires only on state
    // transitions, never on unrelated rebuilds.
    ref.listen<AsyncValue<List<OrderModel>>>(confirmOrderProvider, (
      AsyncValue<List<OrderModel>>? previous,
      AsyncValue<List<OrderModel>> next,
    ) {
      next.whenOrNull(
        // `listen` fires only on transitions, so reaching `data` here means the
        // confirm request just succeeded (never the initial idle state).
        data: (List<OrderModel> placedOrders) {
          // Refresh the orders list so its `total` reflects the just-placed
          // order — this is what makes the first-order welcome voucher stop
          // showing on the (now empty) cart.
          ref.read(getMyOrdersProvider.notifier).refresh();
          // What was just placed no longer belongs to the cart, so drop it:
          // the whole cart for an all-stores checkout, that one store for a
          // single-store one.
          final GetCartViewModel cartNotifier = ref.read(
            getCartProvider.notifier,
          );
          if (widget.storeId == null) {
            cartNotifier.clearVendors();
          } else {
            cartNotifier.removeVendor(widget.storeId!);
          }
          // Hand the confirmation screen the orders the server actually
          // created (with real order numbers), not the preview draft.
          context.pushReplacementNamed(
            AppRoutes.orderConfirmedScreen,
            extra: placedOrders,
          );
        },
        error: (Object error, StackTrace stackTrace) =>
            AppToast.showError(context, error.toString().tr()),
      );
    });

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.checkoutKey.tr(),
        scrollController: _scrollController,
        body: ProviderScope(
          overrides: [
            // A derived override, not a value one: the scope is built once and
            // recomputes this provider itself, so the subtree below is never
            // rebuilt wholesale — only its `select`ing descendants are.
            checkoutModelProvider.overrideWith(
              (Ref ref) => ref.watch(tippedCheckoutProvider),
            ),
          ],
          child: Consumer(
            // `child` is built once, outside the builder, and handed back
            // untouched — so even the error/body swap can't rebuild the body.
            child: SingleChildScrollView(
              controller: _scrollController,
              // Owns the top spacing AppWavedView drops when a scroll controller
              // is wired in, so it scrolls up with the content.
              padding: const EdgeInsets.only(top: 57),
              child: Column(
                spacing: 16,
                children: [
                  const CheckoutBrandCardsSection(),
                  DeliveryAddressCard(
                    onAddressIdChanged: (int? id) {
                      _addressId = id;
                      _reprice();
                    },
                  ),
                  DeliveryInstructionsCard(
                    controller: _instructionsController,
                  ),
                  TipYourDriverView(
                    onTipChanged: (double tip) =>
                        ref.read(driverTipProvider.notifier).state = tip,
                  ),
                  const CheckoutPaymentSection(),
                  const WalletPaymentRow(),
                  const Column(
                    children: <Widget>[
                      PurchaseVouchersStrip(),
                      InvoiceSummarySection(),
                    ],
                  ),

                  ConfirmOrderButton(onConfirm: _onConfirmOrder),
                ],
              ),
            ),
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              // A checkout that never loaded replaces the whole page — the
              // sections below it would have nothing to show. A failed
              // re-price does not: it keeps the checkout it had. Watching the
              // error alone means the loading → data transition doesn't even
              // run this.
              final Object? error = ref.watch(
                checkoutProvider.select(
                  (AsyncValue<CheckoutModel?> state) =>
                      state.hasValue ? null : state.error,
                ),
              );

              if (error != null) {
                return ServerConnectionErrorWidget(
                  message: error.toString().tr(),
                  // Retry through the same endpoint the checkout came from:
                  // the single-store preview when a store id is set, the
                  // all-stores preview otherwise.
                  onRetry: () => ref
                      .read(checkoutProvider.notifier)
                      .checkout(vendorId: widget.storeId, addressId: _addressId),
                );
              }

              return child!;
            },
          ),
        ),
      ),
    );
  }
}
