import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/payment_methods_single_selector.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_items_list.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/choose_payment_method.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/delivery_address_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_methods_card.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              DeliveryAddressCard(),
              Column(
                spacing: 16,
                children: List.generate(4, (index) => CartBrandItemCard()),
              ),
              ['sd'].isEmpty
                  ? ChoosePaymentMethod()
                  : PaymentMethodsCard(),
              PrimaryAppButton(title: 'Confirm Order'),
            ],
          ),
        ),
        appBarTitle: 'Checkout',
      ),
    );
  }
}
