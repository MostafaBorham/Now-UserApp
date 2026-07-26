import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/checkout_shimmers.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/invoice_summary_card.dart';

/// One of the checkout screen's two loading sections: shows
/// [InvoiceSummaryShimmer] until the draft resolves, then the real
/// [InvoiceSummaryCard].
///
/// The watched slice is a plain `bool`, so this wrapper rebuilds only on the
/// loading ⇄ loaded flip; later total changes (applying a coupon, say) rebuild
/// [InvoiceSummaryCard] alone, which watches the order group itself.
class InvoiceSummarySection extends ConsumerWidget {
  const InvoiceSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(
      checkoutModelProvider.select(
        (CheckoutModel? checkout) => checkout == null,
      ),
    );

    return isLoading
        ? const InvoiceSummaryShimmer()
        : const InvoiceSummaryCard();
  }
}
