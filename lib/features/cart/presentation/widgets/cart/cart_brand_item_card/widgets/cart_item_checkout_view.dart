import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_postfix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

class CartItemCheckoutView extends StatelessWidget {
  const CartItemCheckoutView({
    super.key,
    required this.total,
    this.storeId,
    this.onCheckout,
  });

  final String total;
  final int? storeId;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            colors.onTertiaryFixedVariant,
            colors.onSurfaceVariant,
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
                  'Total',
                  style: AppTextStyles.style16SemiBold.copyWith(
                    color: colors.tertiaryContainer,
                  ),
                ),
                NewPriceWidget(
                  color: colors.onSecondary,
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
                title: 'Checkout',
                onTap: () => context.pushNamed(
                  AppRoutes.checkoutScreen,
                  extra: storeId,
                ),
                postfixIcon: Assets
                    .media
                    .images
                    .svg
                    .rightArrowBrokenIcon
                    .svg(),
                buttonPadding: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
