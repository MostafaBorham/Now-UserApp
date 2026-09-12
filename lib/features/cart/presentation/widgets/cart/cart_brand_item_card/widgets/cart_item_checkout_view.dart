import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_postfix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class CartItemCheckoutView extends StatelessWidget {
  const CartItemCheckoutView({
    super.key,
    required this.total,
    this.onCheckout,
  });

  final String total;

  /// Reported to the parent, which drafts the order group for this store and
  /// navigates only once the request succeeded.
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            colors.primary100,
            colors.secondary100,
          ],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Text(
                  LangKeys.totalKey.tr(),
                  style: AppTextStyles.style16SemiBold.copyWith(
                    color: colors.tertiaryContainer,
                  ),
                ),
                NewPriceWidget(
                  color: colors.black,
                  price: total,
                  size: 17,
                ),
              ],
            ),
          ),
          Flexible(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(999),
              clipBehavior: Clip.antiAlias,
              child: PrimaryAppPostfixIconButton(
                title: LangKeys.checkoutKey.tr(),
                onTap: onCheckout,
                postfixIcon: ReverseWidget(
                  child: Assets
                      .media
                      .images
                      .svg
                      .rightArrowBrokenIcon
                      .svg(),
                ),
                buttonPadding: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
