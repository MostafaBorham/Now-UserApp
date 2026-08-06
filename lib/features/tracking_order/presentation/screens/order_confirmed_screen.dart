import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

import '../components/confirmed_order_card.dart';
import '../components/order_confirmed_header.dart';

/// Order Confirmed screen: a success acknowledgement followed by the confirmed
/// order(s), each offering a shortcut into live tracking.
///
/// [orders] are the just-confirmed orders passed from the checkout flow (the
/// `order_group.orders` of the confirmed `CheckoutModel`); one
/// [ConfirmedOrderCard] is rendered per order.
class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key, this.orders = const <OrderModel>[]});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    void goToTracking() => context.pushNamed(AppRoutes.trackOrderScreen);
    final AppColorScheme colors = context.colors;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // width: double.maxFinite,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: AlignmentGeometry.topCenter,
              radius: 0.9,
              colors: [colors.primary200, colors.primary100, Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Column(
              children: [
                const OrderConfirmedHeader(),
                24.hSpace,
                for (final OrderModel order in orders) ...[
                  ConfirmedOrderCard(
                    orderNumber: order.orderNumber ?? '',
                    price: order.total.toStringAsFixed(2),
                    itemsCount: order.items.length,
                    imageUrl:
                        order.vendor.logoUrl ??
                        ConfirmedOrderCard.fallbackImageUrl,
                    onTrack: goToTracking,
                  ),
                  16.hSpace,
                ],
                8.hSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
