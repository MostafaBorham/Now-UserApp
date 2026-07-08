import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/add_notes_field.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_brand_item_card/checkout_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/choose_payment_method.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_address_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/discount_code_item.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/invoice_summary_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/payment_methods_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/tip_your_driver_view.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List methods = ['sasa'];
    return Scaffold(
      body: AppWavedScaffold(
        body: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              DeliveryAddressCard(),
              Column(
                spacing: 16,
                children: List.generate(4, (index) => CheckoutBrandItemCard()),
              ),
              methods.isEmpty ? ChoosePaymentMethod() : PaymentMethodsCard(),
              AspectRatio(
                  aspectRatio: 2,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => DiscountCodeItem(isDimmed: index == 0,),
                    separatorBuilder: (context, index) => 16.wSpace,
                    itemCount: 4,
                  )),
              TipYourDriverView(),
              InvoiceSummaryCard(),
              AddNotesField(),
              methods.isEmpty ? PrimaryAppDisabledButton(title: 'Confirm Order',) : PrimaryAppButton(title: 'Confirm Order'),
            ],
          ),
        ),
        appBarTitle: 'Checkout',
      ),
    );
  }
}

