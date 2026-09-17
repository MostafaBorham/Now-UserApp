import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
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
    final bool isPercentage = deal.discountType == 'percentage';
    final String value = '${formatDouble(deal.discountValue?.toDouble())}';
    const double ticketWidth = 70;
    const double ticketHeight = 35;
    const double fontSize = ticketWidth * 0.17;
    const double angle = -65 * math.pi / 180;
    return Transform.rotate(
      angle: angle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Assets.media.images.svg.discountTicketIcon.svg(
            height: ticketHeight,
            width: ticketWidth,
          ),
          Container(
            width: ticketWidth,
            height: ticketHeight,
            padding: const EdgeInsets.only(left: ticketWidth * 0.23),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
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
