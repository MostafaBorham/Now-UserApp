import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

/// A store's total and its checkout pill.
///
/// The pill only goes live when the server says this store can actually be
/// checked out. When it can't, the reason is spelled out above it instead of
/// being left for the shopper to discover by tapping and waiting for an error.
class CartItemCheckoutView extends StatelessWidget {
  const CartItemCheckoutView({
    super.key,
    required this.pricing,
    this.onCheckout,
  });

  final CartVendorPricingModel pricing;

  /// Reported to the parent, which drafts the order group for this store and
  /// navigates only once the request succeeded. Ignored while
  /// [blockedReason] has something to say.
  final VoidCallback? onCheckout;

  /// Why this store can't be checked out, or `null` when it can.
  ///
  /// Both flags default to blocking, so a payload that carries no pricing
  /// leaves the pill shut rather than letting a draft through to fail
  /// server-side.
  String? get blockedReason {
    if (!pricing.available) return LangKeys.cartStoreUnavailableKey.tr();

    if (!pricing.minOrderMet) {
      // How far under the store's minimum the basket still is. If the subtotal
      // is missing or already above it, quote the minimum itself rather than a
      // zero or a negative.
      final double shortfall = pricing.minOrderValue - pricing.subtotal;

      return LangKeys.cartMinOrderNotMetKey.tr(
        namedArgs: <String, String>{
          'amount': formatMoney(
            shortfall > 0 ? shortfall : pricing.minOrderValue,
          ),
        },
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String? reason = blockedReason;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (reason != null)
          Row(
            spacing: 6,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colors.errorContainer,
              ),
              Expanded(
                child: Text(
                  reason,
                  style: AppTextStyles.style12Medium.copyWith(
                    color: colors.errorContainer,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),
        Container(
          padding: const EdgeInsetsDirectional.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: [colors.primary100, colors.secondary100],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Text(
                      LangKeys.totalKey.tr(),
                      style: AppTextStyles.style16SemiBold.copyWith(
                        color: colors.tertiaryContainer,
                      ),
                    ),
                    NewPriceWidget(
                      color: colors.black,
                      price: formatMoney(pricing.total),
                      fontWeight: FontWeight.bold,
                      size: 17,
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Opacity(
                  opacity: reason == null ? 1 : 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(999),
                    clipBehavior: Clip.antiAlias,
                    child: PrimaryAppButton(
                      titleStyle: AppTextStyles.style14Medium,
                      title: LangKeys.checkoutKey.tr(),
                      onTap: reason == null ? onCheckout : null,
                      postfixIcon: ReverseWidget(
                        child: Assets.media.images.svg.rightArrowBrokenIcon
                            .svg(),
                      ),
                      buttonPadding: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
