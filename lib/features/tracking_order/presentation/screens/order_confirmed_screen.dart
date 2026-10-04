import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

import '../components/confirmed_order_card.dart';
import '../components/order_confirmed_header.dart';







class OrderConfirmedScreen extends ConsumerWidget {
  const OrderConfirmedScreen({super.key, this.orders = const <OrderModel>[]});

  final List<OrderModel> orders;



  void _returnToHome(BuildContext context, WidgetRef ref) {
    ref.read(mainTabIndexProvider.notifier).state = 0;
    context.goNamed(AppRoutes.mainScreen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: AlignmentGeometry.topCenter,
            radius: 0.9,
            colors: [colors.primary200, colors.primary100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const OrderConfirmedHeader(),
                        24.hSpace,
                        for (final OrderModel order in orders) ...[
                          ConfirmedOrderCard(
                            orderNumber: order.orderNumber ?? '',
                            price: formatMoney(order.totalWithTip),
                            itemsCount: order.itemsQuantity,
                            // No logo → the image widget's own placeholder.
                            imageUrl: order.vendor.logoUrl ?? '',
                            onTrack: () => context.pushNamed(
                              AppRoutes.trackOrderScreen,
                              extra: order.uuid,
                            ),
                          ),
                          16.hSpace,
                        ],
                        8.hSpace,
                      ],
                    ),
                  ),
                ),
                UnPrimaryButton(
                  title: LangKeys.returnToHomePageKey.tr(),
                  backgroundColor: colors.neutral200.withValues(alpha: 0.2),
                  borderColor: colors.neutral200.withValues(alpha: 0.7),
                  onTap: () => _returnToHome(context, ref),
                ),
                16.hSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
