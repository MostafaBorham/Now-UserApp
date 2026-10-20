import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/invoice_breakdown.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';

class InvoiceSummaryCard extends ConsumerWidget {
  const InvoiceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    // Falls back to the zeroed group so the card stays renderable even outside
    // a resolved draft; in practice [InvoiceSummarySection] only mounts it once
    // the draft is in.
    final OrderGroupModel orderGroup =
        ref.watch(
          checkoutModelProvider.select(
            (CheckoutModel? checkout) => checkout?.orderGroup,
          ),
        ) ??
        const OrderGroupModel();
    final String codes = ref
        .watch(appliedDiscountsProvider)
        .map((AppliedDiscountModel applied) => applied.code)
        .join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            LangKeys.invoiceSummaryKey.tr(),
            style: AppTextStyles.style16Bold.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          // Every figure is the server's: the checkout is re-priced with the
          // address and applied codes whenever they change, so nothing is
          // patched in here — a local subtraction can't know the tax the
          // discount also removes. The tip alone is added by the app
          // (OrderGroupModel.withTip): the server adds it to the total and to
          // nothing else.
          InvoiceBreakdown(
            subtotal: orderGroup.subtotal,
            tax: orderGroup.tax,
            deliveryFee: orderGroup.deliveryFee,
            driverTip: orderGroup.driverTip,
            total: orderGroup.total,
            discounts: <(String, double)>[
              (
                codes.isEmpty
                    ? LangKeys.discountLabelKey.tr()
                    : '${LangKeys.discountLabelKey.tr()} ($codes)',
                orderGroup.discount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
