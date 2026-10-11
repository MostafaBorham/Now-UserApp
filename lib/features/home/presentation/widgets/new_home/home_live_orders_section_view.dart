import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/enums/order_step_status.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/live_order_track_card.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_live_orders_vm.dart';

/// The four milestones every card draws, in [OrderStatus.stepStatusAt] order.
const List<String> _liveOrderStepKeys = <String>[
  LangKeys.orderAcceptedKey,
  LangKeys.preparingKey,
  LangKeys.onTheWayKey,
  LangKeys.deliveredKey,
];

/// Minutes from now until [isoTimestamp] (never negative), or `null` when the
/// order carries no parseable estimate.
int? _minutesUntil(String? isoTimestamp) {
  final DateTime? target = DateTime.tryParse(isoTimestamp ?? '');
  if (target == null) return null;
  final int minutes = target.difference(DateTime.now()).inMinutes;
  return minutes < 0 ? 0 : minutes;
}

/// The signed-in user's in-flight orders, one card each; a tap opens Track
/// Order. `HomeView` only mounts this while the orders are loading or at least
/// one is live, so it never shows an empty strip.
class HomeLiveOrdersSectionView extends ConsumerWidget {
  const HomeLiveOrdersSectionView({super.key});

  static const double _margin = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<OrderModel>> liveOrders = ref.watch(
      getLiveOrdersProvider,
    );
    final bool isLoading = liveOrders.isLoading;
    final List<OrderModel> orders =
        liveOrders.valueOrNull ?? const <OrderModel>[];

    return LayoutBuilder(
      builder: (context, con) {
        // A lone order fills the strip between even margins rather than
        // sitting off-centre at the strip's 85 % peek width (BUG-035).
        final bool single = !isLoading && orders.length == 1;
        final double cardWidth = single
            ? con.maxWidth - 2 * _margin
            : con.maxWidth * 0.85;
        return SizedBox(
          height: con.maxWidth * 0.3,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: _margin),
            scrollDirection: Axis.horizontal,
            physics: isLoading || single
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: isLoading ? 2 : orders.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (isLoading) {
                return SizedBox(
                  width: cardWidth,
                  child: AppShimmer(
                    child: LiveOrderTrackCard(
                      logoUrl: '',
                      steps: [
                        for (final String labelKey in _liveOrderStepKeys)
                          (labelKey.tr(), OrderStepStatus.pending),
                      ],
                    ),
                  ),
                );
              }

              final OrderModel order = orders[index];
              final OrderStatus status = OrderStatus.fromKey(order.status);
              final String? uuid = order.uuid;
              return SizedBox(
                width: cardWidth,
                child: LiveOrderTrackCard(
                  remainingMinutes: _minutesUntil(order.estimatedDeliveryTime),
                  logoUrl: order.vendor.logoUrl ?? '',
                  steps: [
                    for (final (int i, String labelKey)
                        in _liveOrderStepKeys.indexed)
                      (labelKey.tr(), status.stepStatusAt(i)),
                  ],
                  onTap: uuid == null || uuid.isEmpty
                      ? null
                      : () => context.pushNamed(
                          AppRoutes.trackOrderScreen,
                          extra: uuid,
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
