import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rating_stars.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/success_add_to_cart_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';

class StoreDetailsBrandInfoCard extends ConsumerWidget {
  const StoreDetailsBrandInfoCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final double discountValue = product.activeDeal?.discountValue ?? 0;
    final bool dealIsPercentage = product.activeDeal?.isPercentage ?? true;
    // Same rule as every product card: the deal-adjusted discountPrice is what
    // the cart charges, and the base price is struck through only when a deal
    // really lowers it. This used to print the pre-deal price as the price and
    // strike through the nullable compare_price — `0.00` on most offers.
    final bool hasDeal = product.hasDeal;
    final int productId = product.id ?? -1;
    final cartState = ref.watch(updateCartProductProvider(productId));
    final bool isAddingToCart = cartState.isLoading;
    // How many are in the cart, from the shared cart once it is loaded and the
    // listing's own count until then. The button used to say only "Add to
    // cart", so a product already added looked reset (BUG-022, QA V2).
    final int inCart =
        ref.watch(
          getCartProvider.select(
            (AsyncValue<CartModel> cart) =>
                cart.valueOrNull?.quantityOf(productId),
          ),
        ) ??
        product.cartQuantity ??
        0;

    ref.listen(updateCartProductProvider(productId), (previous, next) {
      next.whenOrNull(
        data: (cart) {
          if (cart == null) return;
          showCartUpdateFeedback(
            context,
            ref,
            productId: productId,
            cart: cart,
          );
        },
        error: (error, _) {
          AppToast.showError(context, error.toString());
        },
      );
    });
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            context.getLocalizedApiText(product.name),
            style: AppTextStyles.style20Bold.copyWith(
              fontSize: 19,
              height: 1.25,
              color: colors.neutral1200,
            ),
          ),
          Text(
            context.getLocalizedApiText(product.description),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.neutral500,
              fontSize: 13,
              height: 1.7,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Text(
                  '${formatDouble(product.rating?.average)} (${product.rating?.total ?? 0})',
                  style: AppTextStyles.style12Regular.copyWith(
                    color: colors.neutral400,
                  ),
                ),
                AppRatingStars(average: product.rating?.average, size: 12),
              ],
            ),
          ),
          Divider(color: colors.neutral200, height: 24),
          Row(
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Row(
                    textDirection: TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      if (hasDeal)
                        OldPriceWidget(
                          color: colors.neutral400,
                          price: formatMoney(product.price),
                          size: 14,
                        ),
                      if (discountValue > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: dealIsPercentage
                              ? Text(
                                  '-${discountValue.toStringAsFixed(0)}%',
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.style12SemiBold.copyWith(
                                    fontSize: 11,
                                    color: colors.white,
                                  ),
                                )
                              : NewPriceWidget(
                                  color: colors.white,
                                  price: formatMoney(discountValue),
                                  size: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                        ),
                    ],
                  ),
                  NewPriceWidget(
                    color: colors.neutral1200,
                    price: formatMoney(
                      hasDeal ? product.discountPrice : product.price,
                    ),
                    size: 28,
                  ),
                ],
              ),
              Expanded(
                child: Material(
                  elevation: 10,
                  color: Colors.transparent,
                  shadowColor: colors.secondaryFixedDim.withValues(alpha: 0.33),
                  borderRadius: BorderRadius.circular(14),
                  child: PrimaryAppPrefixIconButton(
                    isLoading: isAddingToCart,
                    onTap: () {
                      if (product.id == null) return;
                      ref
                          .read(updateCartProductProvider(productId).notifier)
                          .addToCart(1, seededQuantity: product.cartQuantity);
                    },
                    title: LangKeys.addToCartKey.tr(),
                    buttonColor: colors.secondaryFixedDim,
                    prefixIcon: Badge(
                      isLabelVisible: inCart > 0,
                      label: Text('$inCart'),
                      backgroundColor: colors.white,
                      textColor: colors.secondaryFixedDim,
                      child: ReverseWidget(
                        child: Assets.media.images.svg.shoppingCartIcon.svg(
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    buttonRadius: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
