import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_buy_now_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_options_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart_update_feedback.dart';

class ProductActionButtons extends ConsumerWidget {
  const ProductActionButtons({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.onQuantityRejected,
  });

  final int productId;
  final String productName;
  final String productImageUrl;

  /// The server refused the add with a 422. Most often the stock ran out since
  /// the page loaded, so the page reloads the product and shows what's left.
  final VoidCallback onQuantityRejected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;

    final bool isLoading = ref.watch(
      updateCartProductProvider(productId).select((state) => state.isLoading),
    );
    final bool isBuyNow = ref.watch(productBuyNowProvider);
    final bool isAddingToCart = isLoading && !isBuyNow;
    final bool isBuyNowLoading = isLoading && isBuyNow;

    final ProductOptions productOptions = ref.watch(
      productOptionsProvider(productId),
    );

    // Everything in stock is already in the cart: another add is refused.
    final bool cartIsFull = ref.watch(productRemainingProvider) == 0;

    void add({required bool buyNow}) {
      ref.read(productBuyNowProvider.notifier).state = buyNow;
      ref
          .read(updateCartProductProvider(productId).notifier)
          .addToCart(
            stepperQuantity(
              ref.read(productQuantityProvider),
              ref.read(productRemainingProvider),
            ),
            options: productOptions.toBody(),
          );
    }

    ref.listen(updateCartProductProvider(productId), (previous, next) {
      next.whenOrNull(
        data: (cart) {
          if (cart == null) return;
          final bool wasBuyNow = ref.read(productBuyNowProvider);
          ref.read(productBuyNowProvider.notifier).state = false;
          if (wasBuyNow) {
            ref.read(mainTabIndexProvider.notifier).state = 2;
            context.goNamed(AppRoutes.mainScreen);
            return;
          }
          showCartUpdateFeedback(
            context,
            ref,
            productId: productId,
            cart: cart,
          );
        },
        error: (error, _) {
          ref.read(productBuyNowProvider.notifier).state = false;
          AppToast.showError(context, error.toString());
          final int? status = ref
              .read(updateCartProductProvider(productId).notifier)
              .failedStatus;
          if (status == 422) onQuantityRejected();
        },
      );
    });

    final Widget buttons = LayoutBuilder(
      builder: (context, constraints) {
        // The 2:1 button widths share a height, scaled from the 390px design.
        // At that width the row is 358px, including its 10px gap.
        final height = (constraints.maxWidth - 10) * 54 / 348;
        return Row(
          spacing: 10,
          children: [
            Expanded(
              flex: 2,
              child: PrimaryAppButton(
                buttonHeight: height,
                titleStyle: AppTextStyles.style14Medium,
                isLoading: isAddingToCart,
                isDisabled: cartIsFull,
                onTap: () => add(buyNow: false),
                title: LangKeys.addToCartKey.tr(),
                buttonRadius: 8,
                prefixIcon: ReverseWidget(
                  child: Assets.media.images.svg.shoppingCartIcon.svg(
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: UnPrimaryAppButton(
                buttonHeight: height,
                isLoading: isBuyNowLoading,
                title: LangKeys.buyNowKey.tr(),
                titleColor: cartIsFull ? colors.neutral500 : null,
                side: cartIsFull ? BorderSide(color: colors.neutral200) : null,
                onTap: cartIsFull ? null : () => add(buyNow: true),
              ),
            ),
          ],
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cartIsFull
          ? Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Text(
                  LangKeys.maxAlreadyInCartKey.tr(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style12Regular.copyWith(
                    color: colors.neutral500,
                  ),
                ),
                buttons,
              ],
            )
          : buttons,
    );
  }
}
