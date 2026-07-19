import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CartModel> cartState = ref.watch(getCartProvider);

    return AppWavedScaffold(
      appBarTitle: 'Cart',
      body: cartState.when(
        loading: () => CartShimmerView(),
        error: (Object error, StackTrace stackTrace) =>
            ServerConnectionErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(getCartProvider.notifier).getCart(),
            ),
        data: (CartModel cart) => cart.vendors.isEmpty
            ? const NoItemsWidget()
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(3),
                      itemBuilder: (context, index) {
                        return CartBrandItemCard(
                          cartVendor: cart.vendors[index],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return 20.hSpace;
                      },
                      itemCount: cart.vendors.length,
                    ),
                  ),
                  PrimaryAppButton(
                    title: 'Checkout',
                    onTap: () => context.pushNamed(AppRoutes.checkoutScreen),
                  ),
                ],
              ),
      ),
    );
  }
}
