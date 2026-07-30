import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class SuccessAddToCartView extends StatelessWidget {
  const SuccessAddToCartView({
    super.key,
    this.productName = 'MacBook Air 3',
    this.productImageUrl =
        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
    this.title = 'In the shopping cart',
    this.viewCartLabel = 'View cart',
    this.continueShoppingLabel = 'Continue shopping',
    this.onViewCart,
    this.onContinueShopping,
  });

  final String productName;
  final String productImageUrl;
  final String title;
  final String viewCartLabel;
  final String continueShoppingLabel;
  final GestureTapCallback? onViewCart;
  final GestureTapCallback? onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
      TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft halo behind the product badge.
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          // Product image circle with the green success glow.
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.onPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  offset: const Offset(0, 10),
                  blurRadius: 30,
                ),
              ],
            ),
            child: ClipOval(
              child: AppCachedNetworkImage(
                imageUrl: productImageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Success check badge.
          PositionedDirectional(
            start: 4,
            bottom: 4,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 14,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
          Text(
            productName,
            textAlign: TextAlign.center,
            style: AppTextStyles.style14Medium.copyWith(
              color: colors.onSecondary,
            ),
          ),
          15.hSpace,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style20Bold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          8.hSpace,
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: PrimaryAppButton(
                  title: viewCartLabel,
                  onTap: onViewCart,
                ),
              ),
              Expanded(
                child: UnPrimaryAppButton(
                  title: continueShoppingLabel,
                  onTap: onContinueShopping,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}