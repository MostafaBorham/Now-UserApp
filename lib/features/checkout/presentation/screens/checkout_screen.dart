import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/add_notes_field.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_brand_item_card/checkout_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/choose_payment_method.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_address_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/discount_code_item.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/invoice_summary_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/payment_methods_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/tip_your_driver_view.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key, this.storeId});

  /// `null` checks out every store in the cart; a concrete id checks out only
  /// that single store.
  final int? storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List methods = [];
    final AsyncValue<CheckoutModel> checkoutState = ref.watch(
      checkoutProvider(storeId),
    );

    return Scaffold(
      body: AppWavedView(
        appBarTitle: 'Checkout',
        body: checkoutState.when(
          loading: () => const CheckoutShimmerView(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.read(checkoutProvider(storeId).notifier).checkout(),
              ),
          // The resolved draft is exposed to the subtree via [checkoutModelProvider];
          // wiring the individual widgets to it is a later task.
          data: (CheckoutModel checkout) => ProviderScope(
            overrides: [checkoutModelProvider.overrideWithValue(checkout)],
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  DeliveryAddressCard(),
                  Column(
                    spacing: 16,
                    children: checkout.orderGroup.orders
                        .map((order) => CheckoutBrandItemCard(order: order))
                        .toList(),
                  ),
                  methods.isEmpty
                      ? ChoosePaymentMethod(
                          onTap: () =>
                              context.pushNamed(AppRoutes.addPaymentCard),
                        )
                      : PaymentMethodsCard(),
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
                  TipYourDriverView(),
                  InvoiceSummaryCard(),
                  AddNotesField(),
                  methods.isEmpty
                      ? PrimaryAppDisabledButton(title: 'Confirm Order')
                      : PrimaryAppButton(title: 'Confirm Order'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
