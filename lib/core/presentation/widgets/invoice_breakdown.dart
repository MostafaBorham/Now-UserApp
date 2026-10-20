import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

/// The money rows of an invoice summary, shared by checkout and order details:
/// subtotal, VAT, delivery (FREE when it costs nothing), the tip when there is
/// one, each discount as a red deduction, the total with its VAT note, and —
/// when anything was taken off — a green strip with what the discounts saved.
///
/// Every figure is the caller's; nothing here re-derives the total.
class InvoiceBreakdown extends StatelessWidget {
  const InvoiceBreakdown({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    this.driverTip = 0,
    this.discounts = const <(String, double)>[],
  });

  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double driverTip;
  final double total;

  /// Label and amount of each discount; those at zero are left out.
  final List<(String, double)> discounts;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<(String, double)> applied = discounts
        .where(((String, double) discount) => discount.$2 > 0)
        .toList();
    // Summed in halalas, so two shares never drift by a binary-double cent.
    final double savings =
        applied.fold<int>(
          0,
          (int sum, (String, double) discount) =>
              sum + sarDoubleToHalalas(discount.$2),
        ) /
        halalasPerSar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        _InvoiceRow(
          label: LangKeys.subtotalKey.tr(),
          value: _Amount(subtotal, color: colors.black),
        ),
        _InvoiceRow(
          label: LangKeys.vatKey.tr(),
          value: _Amount(tax, color: colors.black),
        ),
        _InvoiceRow(
          label: LangKeys.deliveryFeesKey.tr(),
          value: deliveryFee > 0
              ? _Amount(deliveryFee, color: colors.black)
              : Text(
                  LangKeys.freeKey.tr(),
                  style: AppTextStyles.style14Bold.copyWith(
                    color: colors.primary500Main,
                  ),
                ),
        ),
        if (driverTip > 0)
          _InvoiceRow(
            label: LangKeys.driverTipKey.tr(),
            value: _Amount(driverTip, color: colors.black),
          ),
        for (final (String label, double amount) in applied)
          _InvoiceRow(
            label: label,
            value: _Amount(
              amount,
              color: colors.errorContainer,
              deduction: true,
            ),
          ),
        Divider(height: 1, thickness: 0.5, color: colors.neutral400),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            _InvoiceRow(
              label: LangKeys.totalKey.tr(),
              isTotal: true,
              value: NewPriceWidget(
                color: colors.primary500Main,
                price: formatMoney(total),
                size: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              LangKeys.allPricesIncludeVatKey.tr(),
              style: AppTextStyles.style12Regular.copyWith(
                color: colors.neutral500,
              ),
            ),
          ],
        ),
        if (savings > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primary100,
              borderRadius: AppBorderRadius.brCircular8,
            ),
            child: Row(
              spacing: 8,
              children: [
                Assets.media.images.svg.discount.svg(
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    colors.primaryContainer,
                    BlendMode.srcIn,
                  ),
                ),
                Expanded(
                  child: Text(
                    LangKeys.totalSavingsKey.tr(),
                    style: AppTextStyles.style14SemiBold.copyWith(
                      color: colors.primaryContainer,
                    ),
                  ),
                ),
                NewPriceWidget(
                  color: colors.primaryContainer,
                  price: formatMoney(savings),
                  size: 15,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A label on the start side and its [value] on the end side.
class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final Widget value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            label,
            style:
                (isTotal
                        ? AppTextStyles.style16SemiBold
                        : AppTextStyles.style14Regular)
                    .copyWith(color: context.colors.black),
          ),
        ),
        value,
      ],
    );
  }
}

/// A riyal amount; a [deduction] reads "− ﷼ 15.00".
class _Amount extends StatelessWidget {
  const _Amount(this.value, {required this.color, this.deduction = false});

  final double value;
  final Color color;
  final bool deduction;

  static const double _size = 15;

  @override
  Widget build(BuildContext context) {
    final Widget price = NewPriceWidget(
      color: color,
      price: formatMoney(value),
      size: _size,
      fontWeight: FontWeight.w700,
    );
    if (!deduction) return price;

    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        Text(
          '−',
          style: AppTextStyles.style28SemiBold.copyWith(
            color: color,
            fontSize: _size * 0.9,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        price,
      ],
    );
  }
}
