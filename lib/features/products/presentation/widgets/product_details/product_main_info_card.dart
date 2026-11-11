import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/price_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/texts/out_of_stock_label.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/texts/expandable_text.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_max_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_name.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_discount_ticket.dart';

class ProductMainInfoCard extends ConsumerWidget {
  const ProductMainInfoCard({
    super.key,
    required this.productNameKey,
    required this.titleProgress,
  });

  final GlobalKey productNameKey;
  final ValueListenable<double> titleProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final product = ref.watch(productProvider);
    final productQuantityController = ref.read(
      productQuantityProvider.notifier,
    );
    final productQuantity = ref.watch(productQuantityProvider);
    final int maxQuantity = ref.watch(productMaxQuantityProvider);
    final int minQuantity = product.minOrderQuantity ?? 1;
    ref.listen<int>(productMaxQuantityProvider, (int? previous, int next) {
      if (productQuantityController.state > next) {
        productQuantityController.state = next < 1 ? 1 : next;
      }
    });
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppBoxShadows.greyElevation3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: titleProgress,
                  builder: (_, double progress, Widget? child) => Visibility(
                    visible: progress == 0,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: child!,
                  ),
                  child: ProductDetailsName(
                    key: productNameKey,
                    name: context.getLocalizedApiText(product.name),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 8,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary100.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Assets.media.images.svg.trustIcon.svg(
                                colorFilter: ColorFilter.mode(
                                  colors.primary500Main,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Text(
                                LangKeys.trustedProductKey.tr(),
                                style: AppTextStyles.style12SemiBold.copyWith(
                                  color: colors.primary700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if ((product.stock ?? 1) < 1)
                      const Flexible(
                        child: OutOfStockLabel(fontSize: 15, wrapText: true),
                      )
                    else if (maxQuantity < 1)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6,
                            children: [
                              Assets.media.images.svg.tickCircle.svg(
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  colors.primary500Main,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  LangKeys.allStockAddedToCartKey.tr(),
                                  style: AppTextStyles.style12SemiBold.copyWith(
                                    color: colors.primary500Main,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
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
                              onTap: productQuantity < maxQuantity
                                  ? () {
                                      productQuantityController.state++;
                                    }
                                  : null,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: productQuantity < maxQuantity
                                      ? colors.tertiaryContainer
                                      : colors.neutral200,
                                  shape: BoxShape.circle,
                                  boxShadow: AppBoxShadows.blackBottomShadow2,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 14,
                                    color: colors.white,
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
                                  color: colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: productQuantity > minQuantity
                                  ? () {
                                      productQuantityController.state--;
                                    }
                                  : null,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: productQuantity > minQuantity
                                      ? colors.white
                                      : colors.neutral200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: colors.neutral400,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          spacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                NewPriceWidget(
                                  size: con.maxWidth * 0.11,
                                  symbolSize: con.maxWidth * 0.07,
                                  color: colors.neutral1200,
                                  price: formatTrimmedPrice(
                                    product.discountPrice ?? product.price,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                                if (product.hasDeal)
                                  OldPriceWidget(
                                    color: colors.neutral500,
                                    size: con.maxWidth * 0.043,
                                    price: formatTrimmedPrice(product.price),
                                  ),
                              ],
                            ),
                            if (product.activeDeal != null &&
                                (product.activeDeal!.discountValue ?? 0) > 0)
                              ProductDiscountTicket(deal: product.activeDeal!),
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
                            rateRatio:
                                '${formatDouble(product.rating?.average)}',
                            rateCount: '${product.rating?.total ?? 0}',
                            size: 12,
                            starSize: 16,
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
              spacing: 8,
              children: [
                Text(
                  LangKeys.descriptionKey.tr(),
                  style: AppTextStyles.style16Bold.copyWith(
                    color: colors.black,
                    fontSize: 15,
                  ),
                ),
                ExpandableText(
                  text: context.getLocalizedApiText(product.description),
                  style: AppTextStyles.style13Regular.copyWith(
                    color: colors.greyText,
                    height: 1.8,
                  ),
                  maxCharacters: 150,
                  seeMoreText: LangKeys.seeMoreKey.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
