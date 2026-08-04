import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

import '../components/confirmed_order_card.dart';
import '../components/order_confirmed_header.dart';

/// Order Confirmed screen: a success acknowledgement followed by the confirmed
/// order(s), each offering a shortcut into live tracking.
class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void goToTracking() =>
        context.pushNamed(AppRoutes.trackOrderScreen);
    final AppColorScheme colors = context.colors;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // width: double.maxFinite,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: AlignmentGeometry.topCenter,
              radius: 0.9,
              colors: [colors.tertiary, colors.onSurfaceVariant, Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Column(
              children: [
                const OrderConfirmedHeader(),
                24.hSpace,
                ConfirmedOrderCard(onTrack: goToTracking),
                16.hSpace,
                ConfirmedOrderCard(onTrack: goToTracking),
                24.hSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
