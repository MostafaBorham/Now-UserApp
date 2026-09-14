import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/idempotency_key.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_brand_cards_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/confirm_order_button.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_address_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_instructions_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/invoice_summary_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/purchase_vouchers_strip.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/checkout_payment_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/tip_your_driver_view.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/confirm_order_vm.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
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
  double _driverTip = 0;

  int? _addressId;

  // Drives the wave-flatten animation in [AppWavedView]: as the body scrolls
  // off the top the header wave straightens out.
  final ScrollController _scrollController = ScrollController();

  // Idempotency key for the place request: reused across retries of an
  // unchanged order, rotated when the order changes or after one is placed.
  final IdempotencyKey _idempotencyKey = IdempotencyKey();

  @override
  void dispose() {
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

    final String? orderGroupUuid = checkout.orderGroup.uuid;
    // The wallet wins while its checkbox is ticked (the default); untick it and
    // the draft's own method pays. ponytail: there is no split-payment field on
    // the confirm request yet, so the shortfall the note promises is settled
    // server-side — the app only says which method leads.
    final String? paymentMethod = ref.read(walletPaymentProvider)
        ? 'wallet'
        : checkout.orderGroup.paymentMethod;
    final List<AppliedDiscountModel> coupons = ref.read(
      appliedDiscountsProvider,
    );
    const String? notes = null;

    final String idempotencyKey = _idempotencyKey.forRequest(
      _placeFingerprint(
        addressId: _addressId,
        driverTip: _driverTip,
        notes: notes,
        paymentMethod: paymentMethod,
        coupons: coupons,
      ),
    );

    ref
        .read(confirmOrderProvider.notifier)
        .confirmOrder(
          orderGroupUuid: orderGroupUuid ?? '',
          idempotencyKey: idempotencyKey,
          addressId: _addressId!,
          paymentMethod: paymentMethod,
          driverTip: _driverTip,
          notes: notes,
          coupons: coupons,
        );
  }

  /// A fingerprint of exactly the fields the place request carries (and the
  /// server hashes): address, tip, notes, payment method and the *coupon* codes
  /// (vouchers aren't sent). Two submits with the same fingerprint are the same
  /// order and may share an idempotency key.
  String _placeFingerprint({
    int? addressId,
    double? driverTip,
    String? notes,
    String? paymentMethod,
    List<AppliedDiscountModel> coupons = const <AppliedDiscountModel>[],
  }) {
    final Map<int, String> couponMap = <int, String>{
      for (final AppliedDiscountModel d in coupons)
        if (!d.isVoucher) d.vendorId: d.code,
    };
    final String sortedCoupons =
        (couponMap.entries.toList()..sort(
              (MapEntry<int, String> a, MapEntry<int, String> b) =>
                  a.key.compareTo(b.key),
            ))
            .map((MapEntry<int, String> e) => '${e.key}:${e.value}')
            .join(',');
    return <String>[
      '${addressId ?? ''}',
      '$driverTip',
      notes ?? '',
      paymentMethod ?? 'wallet',
      sortedCoupons,
    ].join('|');
  }

  @override
  Widget build(BuildContext context) {
    // Nothing is `watch`ed here on purpose: this build must run once, or the
    // whole body would be rebuilt with it.

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
          // A confirmed placement: consume the key so any later order is
          // treated as new rather than replaying this one.
          _idempotencyKey.markConsumed();
          // Refresh the orders list so its `total` reflects the just-placed
          // order — this is what makes the first-order welcome voucher stop
          // showing on the (now empty) cart.
          ref.read(getMyOrdersProvider.notifier).getOrders();
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
            AppToast.showError(context, error.toString()),
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
              (Ref ref) => ref.watch(checkoutProvider).valueOrNull,
            ),
          ],
          child: Consumer(
            // `child` is built once, outside the builder, and handed back
            // untouched — so even the error/body swap can't rebuild the body.
            child: SingleChildScrollView(
              controller: _scrollController,
              // Owns the top spacing AppWavedView drops when a scroll controller
              // is wired in, so it scrolls up with the content and flattens the
              // wave.
              padding: const EdgeInsets.only(top: 57),
              child: Column(
                spacing: 16,
                children: [
                  const CheckoutBrandCardsSection(),
                  DeliveryAddressCard(
                    onAddressIdChanged: (int? id) => _addressId = id,
                  ),
                  const DeliveryInstructionsCard(),
                  TipYourDriverView(
                    initialTip: 2,
                    onTipChanged: (double tip) => _driverTip = tip,
                  ),
                  const CheckoutPaymentSection(),
                  const PurchaseVouchersStrip(),
                  const InvoiceSummarySection(),

                  ConfirmOrderButton(onConfirm: _onConfirmOrder),
                  10.hSpace,
                ],
              ),
            ),
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              // A failed draft still replaces the whole page — the sections
              // below it would have nothing to show. Watching the error alone
              // means the loading → data transition doesn't even run this.
              final Object? error = ref.watch(
                checkoutProvider.select(
                  (AsyncValue<CheckoutModel?> state) => state.error,
                ),
              );

              if (error != null) {
                return ServerConnectionErrorWidget(
                  message: error.toString(),
                  // Retry through the same endpoint the draft came from: the
                  // single-store preview when a store id is set, the all-stores
                  // preview otherwise.
                  onRetry: () {
                    final CheckoutViewModel checkoutVm = ref.read(
                      checkoutProvider.notifier,
                    );
                    final int? storeId = widget.storeId;
                    if (storeId == null) {
                      checkoutVm.checkout();
                    } else {
                      checkoutVm.checkoutForSingleStore(vendorId: storeId);
                    }
                  },
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
