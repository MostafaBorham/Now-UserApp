import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_brand_item_card/checkout_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_shimmers.dart';

/// One of the checkout screen's two loading sections: shows
/// [CheckoutBrandCardsShimmer] until the draft resolves, then a
/// [CheckoutBrandItemCard] per store in the group.
///
/// Watching only `orders` keeps the rest of the screen out of this rebuild —
/// the siblings never see the draft arrive.
class CheckoutBrandCardsSection extends ConsumerWidget {
  const CheckoutBrandCardsSection({super.key, this.storeId});

  /// The checkout provider family key (the screen's `storeId`): `null` for the
  /// all-stores flow, a concrete id for the single-store flow.
  final int? storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `null` while the draft is loading — the model provider itself is null
    // until then.
    final List<DraftOrderModel>? orders = ref.watch(
      checkoutModelProvider.select(
        (CheckoutModel? checkout) => checkout?.orderGroup.orders,
      ),
    );

    if (orders == null) return const CheckoutBrandCardsShimmer();

    return Column(
      spacing: 16,
      children: orders
          .map(
            (DraftOrderModel order) =>
                CheckoutBrandItemCard(order: order, storeId: storeId),
          )
          .toList(),
    );
  }
}
