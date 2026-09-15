import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/wallet_transaction_status.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';






class WalletHistoryItem extends StatelessWidget {
  const WalletHistoryItem({super.key, required this.transaction});

  final WalletTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final WalletTransactionMerchant? merchant = transaction.merchant;
    final String logoUrl = merchant?.logoUrl ?? '';
    final String title = context.getLocalizedApiText(merchant?.name);


    final WalletTransactionStatus status = transaction.status;


    final String statusLabel = transaction.displayStatus ?? status.name;
    final String price = transaction.amountLabel ?? '';





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



                            overflow: TextOverflow.visible,
                            style: AppTextStyles.style14SemiBold.copyWith(
                              color: colors.black,
                              fontSize: con.maxWidth * 0.04,
                              overflow: TextOverflow.visible,
                            ),
                          ),



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
