import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/texts/expandable_text.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';

class ProductMainInfoCard extends ConsumerWidget {
  const ProductMainInfoCard({
    super.key,
    this.productName = 'MacBook Air 3',
    this.storeName = 'Bandeh Store',
    this.storeLogoUrl =
        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
    this.oldPrice = '10',
    this.newPrice = '10',
    this.rate = '4.5',
    this.rateCount = '12',
    this.description =
        'Almarai Milk 2 Liters: Fresh, high-quality milk with a creamy taste '
        'and smooth texture. Provides essential nutrients like calcium and '
        'vitamin D for strong bones and a healthy body',
    this.isTrusted = true,
    this.trustedBadgeLabel = 'منتج موثوق',
  });

  final String productName;
  final String storeName;
  final String storeLogoUrl;
  final String oldPrice;
  final String newPrice;
  final String rate;
  final String rateCount;
  final String description;
  final bool isTrusted;
  final String trustedBadgeLabel;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final product = ref.watch(productProvider);
    final productQuantityController = ref.read(
      productQuantityProvider.notifier,
    );
    final productQuantity = ref.watch(
      productQuantityProvider,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(
              alpha: 0.3,
            ), // #0000000F (black 6%)
            offset: const Offset(0, 2),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: isTrusted
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (isTrusted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Text(
                        trustedBadgeLabel,
                        style: AppTextStyles.style12SemiBold.copyWith(
                          color: colors.onPrimaryFixedVariant,
                        ),
                      ),
                      Assets.media.images.svg.trustIcon.svg(
                        colorFilter: ColorFilter.mode(
                          colors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    InkWell(
                      onTap: () {
                        productQuantityController.state++;
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.tertiaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: AppBoxShadows.blackBottomShadow2,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 14,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        productQuantity.toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style16Bold.copyWith(
                          color: colors.onSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: productQuantity > 1
                          ? () {
                              productQuantityController.state--;
                            }
                          : null,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            size: 14,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                context.getLocalizedApiText(product.name),
                overflow: TextOverflow.visible,
                style: AppTextStyles.style24Bold.copyWith(
                  color: colors.onSecondary,
                  fontSize: 22,
                ),
              ),
              Row(
                spacing: 8,
                children: [
                  CircularBrandLogo(
                    radius: 18,
                    backgroundColor: colors.onPrimaryContainer,
                    logoUrl: product.vendor?.logoUrl ?? '',
                  ),
                  Text(
                    context.getLocalizedApiText(product.vendor?.name),
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              LayoutBuilder(
                builder: (context, con) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: TextDirection.ltr,
                        spacing: 4,
                        children: [
                          OldPriceWidget(
                            color: colors.onSurface,
                            size: con.maxWidth * 0.04,
                            price: '${product.comparePrice}',
                          ),
                          NewPriceWidget(
                            size: con.maxWidth * 0.07,
                            color: colors.onTertiaryFixed,
                            price: '${product.price}',
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: AppRateWidget(
                          starColor: colors.surface,
                          rateColor: colors.tertiaryContainer,
                          rateRatio: rate,
                          rateCount: rateCount,
                          size: 15,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                LangKeys.descriptionKey.tr(),
                style: AppTextStyles.style16Bold.copyWith(
                  color: colors.onSecondary,
                  fontSize: 15,
                ),
              ),
              ExpandableText(
                text: context.getLocalizedApiText(product.description),
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.onSurface,
                ),
                maxCharacters: 150,
                seeMoreText: LangKeys.seeMoreKey.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
