import 'dart:math' as math;

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
///
/// The ticket is tilted like the Figma design: the tag's grommet points up and
/// to the right. The base [discountTicketIcon] is a horizontal tag with its
/// grommet on the trailing edge, so reaching the design angle means rotating it
/// ~65° counter-clockwise off the horizontal. This same tilt is kept in both
/// LTR and RTL — the ticket does not mirror with the layout direction.
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
    const double fontSize = ticketWidth * 0.17;
    // 65° off the horizontal reproduces the Figma tilt (a vertical tag turned
    // 25° from upright), counter-clockwise. Kept identical in LTR and RTL.
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
          // Constrain the text to the ticket bounds and scale it down so it
          // never grows past the image or overflows its edges.
          Container(
            width: ticketWidth,
            height: ticketHeight,
            // The leading ~23% of the ticket image is the grommet/pointed tip,
            // not flat label space. Inset the text by that amount so aligning it
            // to the left lands on the body's edge, not over the tip/hole.
            // Fixed to the left (not direction-aware) since the ticket itself
            // never mirrors with the layout direction.
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
