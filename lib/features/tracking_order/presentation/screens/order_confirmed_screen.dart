import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
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
          width: double.maxFinite,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: AlignmentDirectional.topCenter,
              radius: 0.9,
              // The design fades to white early — most of the page is plain
              // white with only the header tinted.
              stops: const [0, 0.11, 1],
              colors: [colors.primary200, colors.primary100, Colors.white],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
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
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: UnPrimaryButton(
          title: LangKeys.returnToHomePageKey.tr(),
          onTap: () => context.goNamed(AppRoutes.mainScreen),
          backgroundColor: colors.primaryFixed,
          borderColor: colors.neutral200,
          titleColor: colors.neutral1200,
          titleStyle: AppTextStyles.style16Medium,
        ),
      ),
    );
  }
}
