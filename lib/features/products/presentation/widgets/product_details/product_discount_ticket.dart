// Hide easy_localization's re-exported intl TextDirection so Flutter's stays in
// scope for the LTR price row; the `.tr()` extension is unaffected.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

/// A red ticket badge shown at the top of the product details screen for a
/// product carrying an active deal. It reads the discount straight off the
/// [deal]: a percentage deal renders `"N% Off"`, any other type renders the
/// discount as a price via [NewPriceWidget]. The amount always comes from
/// [ActiveDealModel.discountValue].
class ProductDiscountTicket extends StatelessWidget {
  const ProductDiscountTicket({super.key, required this.deal});

  final ActiveDealModel deal;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isPercentage = deal.discountType == 'percentage';
    final String value = '${formatDouble(deal.discountValue?.toDouble())}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Assets.media.images.svg.discountTicketIcon.svg(
            height: 18,
            colorFilter: ColorFilter.mode(colors.white, BlendMode.srcIn),
          ),
          if (isPercentage)
            Text(
              '$value% ${LangKeys.discountKey.tr()}',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.style14Bold.copyWith(color: colors.white),
            )
          else
            NewPriceWidget(
              color: colors.white,
              price: value,
              size: 15,
              fontWeight: FontWeight.bold,
            ),
        ],
      ),
    );
  }
}
