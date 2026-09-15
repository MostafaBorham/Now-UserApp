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



  final int? storeId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  double _driverTip = 0;

  int? _addressId;



  final TextEditingController _instructionsController = TextEditingController();



  final ScrollController _scrollController = ScrollController();



  final IdempotencyKey _idempotencyKey = IdempotencyKey();

  @override
  void dispose() {
    _instructionsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onConfirmOrder() {


    final CheckoutModel? checkout = ref.read(checkoutProvider).valueOrNull;

    if (checkout == null) return;




    if (_addressId == null) {
      AppToast.showError(context, LangKeys.pleaseSelectAddressKey.tr());
      return;
    }

    final String? orderGroupUuid = checkout.orderGroup.uuid;




    final String? paymentMethod = ref.read(walletPaymentProvider)
        ? 'wallet'
        : checkout.orderGroup.paymentMethod;
    final List<AppliedDiscountModel> coupons = ref.read(
      appliedDiscountsProvider,
    );
    final String deliveryInstructions = _instructionsController.text.trim();

    final String idempotencyKey = _idempotencyKey.forRequest(
      _placeFingerprint(
        addressId: _addressId,
        driverTip: _driverTip,
        deliveryInstructions: deliveryInstructions,
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
          deliveryInstructions: deliveryInstructions,
          coupons: coupons,
        );
  }





  String _placeFingerprint({
    int? addressId,
    double? driverTip,
    String? deliveryInstructions,
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
      deliveryInstructions ?? '',
      paymentMethod ?? 'wallet',
      sortedCoupons,
    ].join('|');
  }

  @override
  Widget build(BuildContext context) {







    ref.listen<AsyncValue<List<OrderModel>>>(confirmOrderProvider, (
      AsyncValue<List<OrderModel>>? previous,
      AsyncValue<List<OrderModel>> next,
    ) {
      next.whenOrNull(


        data: (List<OrderModel> placedOrders) {


          _idempotencyKey.markConsumed();



          ref.read(getMyOrdersProvider.notifier).getOrders();



          final GetCartViewModel cartNotifier = ref.read(
            getCartProvider.notifier,
          );
          if (widget.storeId == null) {
            cartNotifier.clearVendors();
          } else {
            cartNotifier.removeVendor(widget.storeId!);
          }


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



            checkoutModelProvider.overrideWith(
              (Ref ref) => ref.watch(checkoutProvider).valueOrNull,
            ),
          ],
          child: Consumer(


            child: SingleChildScrollView(
              controller: _scrollController,



              padding: const EdgeInsets.only(top: 57),
              child: Column(
                spacing: 16,
                children: [
                  const CheckoutBrandCardsSection(),
                  DeliveryAddressCard(
                    onAddressIdChanged: (int? id) => _addressId = id,
                  ),
                  DeliveryInstructionsCard(
                    controller: _instructionsController,
                  ),
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



              final Object? error = ref.watch(
                checkoutProvider.select(
                  (AsyncValue<CheckoutModel?> state) => state.error,
                ),
              );

              if (error != null) {
                return ServerConnectionErrorWidget(
                  message: error.toString(),



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
