import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_coupon_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_coupons_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/add_notes_field.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_brand_cards_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/confirm_order_button.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_address_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/discount_code_item.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/invoice_summary_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/checkout_payment_section.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/tip_your_driver_view.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/confirm_order_vm.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
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
  String _notes = '';


  int? _addressId;

  void _onConfirmOrder() {
    // Read from the async provider rather than [checkoutModelProvider]: the
    // latter only exists inside the scope below, which this `ref` is above.
    final CheckoutModel? checkout = ref.read(checkoutProvider).valueOrNull;

    if (checkout == null) return;

    final String? orderGroupUuid = checkout.orderGroup.uuid;
    final String? paymentMethod = checkout.orderGroup.paymentMethod;
    final List<AppliedCouponModel> coupons = ref.read(appliedCouponsProvider);

    ref
        .read(confirmOrderProvider.notifier)
        .confirmOrder(
          orderGroupUuid: orderGroupUuid ?? '',
          addressId: _addressId ?? 3,
          paymentMethod: paymentMethod,
          driverTip: _driverTip,
          notes: _notes.trim().isEmpty ? null : _notes.trim(),
          coupons: coupons,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Nothing is `watch`ed here on purpose: this build must run once, or the
    // whole body would be rebuilt with it.

    // React to the outcome of a confirm-order request: on success push the
    // confirmation screen, on failure surface the message via the shared
    // error snackbar. Uses `listen` (not `watch`) so this fires only on state
    // transitions, never on unrelated rebuilds.
    ref.listen<AsyncValue<void>>(confirmOrderProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      next.whenOrNull(
        // `listen` fires only on transitions, so reaching `data` here means the
        // confirm request just succeeded (never the initial idle state).
        data: (_) {
          final CheckoutModel? checkout =
              ref.read(checkoutProvider).valueOrNull;
          context.pushReplacementNamed(
            AppRoutes.orderConfirmedScreen,
            extra: checkout?.orderGroup.orders ?? const <OrderModel>[],
          );
        },
        error: (Object error, StackTrace stackTrace) =>
            ErrorSnackBar.show(context, error.toString()),
      );
    });

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.checkoutKey.tr(),
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
              child: Column(
                spacing: 16,
                children: [
                  const CheckoutBrandCardsSection(),
                  DeliveryAddressCard(
                    onAddressIdChanged: (int? id) => _addressId = id,
                  ),
                  TipYourDriverView(
                    initialTip: 2,
                    onTipChanged: (double tip) => _driverTip = tip,
                  ),
                  const CheckoutPaymentSection(),
                  AspectRatio(
                    aspectRatio: 2,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) =>
                          DiscountCodeItem(isDimmed: index == 0),
                      separatorBuilder: (context, index) => 16.wSpace,
                      itemCount: 4,
                    ),
                  ),
                  AddNotesField(onChanged: (String notes) => _notes = notes),
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
                  onRetry: () => ref
                      .read(checkoutProvider.notifier)
                      .checkout(vendorId: widget.storeId),
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