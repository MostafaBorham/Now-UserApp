import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

/// A discount ticket shown at the top of the product details screen for a
/// product carrying an active deal. It renders the [discountTicketIcon] asset
/// with the discount text laid over it in white: a percentage deal renders
/// `"N%"`, any other type renders the discount as a price via [NewPriceWidget].
/// The amount always comes from [ActiveDealModel.discountValue].
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
    // Text scales with the ticket width so it always fits the same way.
    const double fontSize = ticketWidth * 0.2;
    return Stack(
      alignment: Alignment.center,
      children: [
        Assets.media.images.svg.discountTicketIcon.svg(
          height: ticketHeight,
          width: ticketWidth,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 5),
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
      ],
    );
  }
}
