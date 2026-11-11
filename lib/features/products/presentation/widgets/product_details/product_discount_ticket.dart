import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

class ProductDiscountTicket extends StatelessWidget {
  const ProductDiscountTicket({super.key, required this.deal});

  final ActiveDealModel deal;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isPercentage = deal.isPercentage;
    // Percentages read best trimmed (20%, not 20.00%); a fixed amount is money.
    final String value = isPercentage
        ? '${formatDouble(deal.discountValue?.toDouble())}'
        : formatMoney(deal.discountValue?.toDouble());
    const double ticketWidth = 34;
    const double ticketHeight = 20.3;
    const double fontSize = ticketWidth * 0.31;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double angle = (isRtl ? -23.6 : 23.6) * math.pi / 180;
    return Transform.rotate(
      angle: angle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.flip(
            flipX: !isRtl,
            child: Assets.media.images.svg.discountTicketIcon.svg(
              height: ticketHeight,
              width: ticketWidth,
            ),
          ),
          Container(
            width: ticketWidth,
            height: ticketHeight,
            padding: const EdgeInsetsDirectional.only(end: ticketWidth * 0.1),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: isPercentage
                  ? Text(
                      '$value%',
                      textDirection: TextDirection.ltr,
                      style: AppTextStyles.style14Bold.copyWith(
                        color: colors.white,
                        fontSize: fontSize,
                      ),
                    )
                  : NewPriceWidget(
                      color: colors.white,
                      price: value,
                      size: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
