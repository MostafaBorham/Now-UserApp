import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/wallet_transaction_status.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';

/// One row of the wallet transaction history. Sizes to its own content so every
/// field — merchant name, status and amount — is shown in full: the merchant
/// name wraps onto new lines instead of ellipsising, the amount keeps its
/// natural width, and only an over-long status chip is scaled down to stay
/// within its capped width.
class WalletHistoryItem extends StatelessWidget {
  const WalletHistoryItem({super.key, required this.transaction});

  final WalletTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final WalletTransactionMerchant? merchant = transaction.merchant;
    final String logoUrl = merchant?.logoUrl ?? '';
    final String title = context.getLocalizedApiText(merchant?.name);
    // The status drives the chip's colors and the amount color, mapped through
    // [WalletTransactionStatus] so the colors aren't re-hardcoded here.
    final WalletTransactionStatus status = transaction.status;
    // The human-readable chip label — the server's `display_status`, falling
    // back to the raw status value the status carries.
    final String statusLabel = transaction.displayStatus ?? status.name;
    final String price = transaction.amountLabel ?? '';
    // The transaction date, from `created_at`, shown as a localized numeric
    // `dd-MM-yyyy` (e.g. 10-04-2026, Arabic-Indic digits under ar-EG) via the
    // shared [context.getLocalizedNumericApiDate]; it returns an empty string
    // when the server omits or sends an unparseable timestamp, so the
    // `if (date.isNotEmpty)` below hides the row with no extra guard here.
    final String date = context.getLocalizedNumericApiDate(
      apiDateTimeStamp: transaction.createdAt,
    );

    return LayoutBuilder(
      builder: (context, con) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: colors.neutral500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(con.maxWidth * 0.1),
          ),
          child: Row(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Merchant logo + name — the name wraps onto new lines and is
              // never truncated, taking whatever width the status chip and
              // amount leave behind.
              Expanded(
                child: Row(
                  spacing: 12,
                  children: [
                    CircularBrandLogo(
                      radius: con.maxWidth * 0.07,
                      logoUrl: logoUrl,
                      backgroundColor: colors.white,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            softWrap: true,
                            // The shared text style bakes in `overflow:
                            // ellipsis`; override it so the merchant name wraps
                            // in full instead of being truncated.
                            overflow: TextOverflow.visible,
                            style: AppTextStyles.style14SemiBold.copyWith(
                              color: colors.black,
                              fontSize: con.maxWidth * 0.04,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          // The date sits under the merchant name; hidden when
                          // the server omits it, and shown in full (no ellipsis)
                          // just like the merchant name.
                          if (date.isNotEmpty)
                            Text(
                              date,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: AppTextStyles.style12Regular.copyWith(
                                color: colors.onPrimaryFixed.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: con.maxWidth * 0.03,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Status chip — hugs its text, but never grows past a capped
              // width; a longer status is scaled down to fit inside that cap.
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: con.maxWidth * 0.3),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: status.statusColor(colors),
                    borderRadius: AppBorderRadius.brCircular30,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      statusLabel,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style12Medium.copyWith(
                        color: status.statusTextColor(colors),
                      ),
                    ),
                  ),
                ),
              ),
              // Amount — the server-formatted `amount_label`, shown at its
              // natural width (never scaled).
              Directionality(
                textDirection: TextDirection.ltr,
                child: NewPriceWidget(
                  color: status.priceColor(colors),
                  price: price,
                  size: con.maxWidth * 0.04,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
