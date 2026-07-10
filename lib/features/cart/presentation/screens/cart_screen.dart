import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWavedScaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(3),
              itemBuilder: (context, index) {
                return const CartBrandItemCard(readyToCheckout: true,);
              },
              separatorBuilder: (context, index) {
                return 20.hSpace;
              },
              itemCount: 5,
            ),
          ),
          PrimaryAppButton(title: 'Checkout',onTap: () => context.pushNamed(AppRoutes.checkoutScreen),)
        ],
      ),
      appBarTitle: 'Cart',
    );
  }
}