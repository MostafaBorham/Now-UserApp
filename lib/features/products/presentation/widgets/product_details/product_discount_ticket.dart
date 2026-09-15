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
    return Stack(
      alignment: Alignment.center,
      children: [
        Assets.media.images.svg.discountTicketIcon.svg(height: 48),
        if (isPercentage)
          Text(
            '$value%',
            textDirection: TextDirection.ltr,
            style: AppTextStyles.style14Bold.copyWith(color: colors.white),
          )
        else
          NewPriceWidget(
            color: colors.white,
            price: value,
            size: 13,
            fontWeight: FontWeight.bold,
          ),
      ],
    );
  }
}
