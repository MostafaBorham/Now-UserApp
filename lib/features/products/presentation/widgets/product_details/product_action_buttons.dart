import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_buy_now_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_options_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/success_add_to_cart_view.dart';

class ProductActionButtons extends ConsumerWidget {
  const ProductActionButtons({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
  });

  final int productId;
  final String productName;
  final String productImageUrl;

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
          // Routed through the shared helper so this screen follows the same
          // rule as every other place a cart line changes: the sheet the first
          // time the product joins the cart, a toast for a later quantity
          // change. Going straight to the sheet here would confirm an add that
          // was really an increment.
          showCartUpdateFeedback(
            context,
            ref,
            productId: productId,
            cart: cart,
            // Back to whatever list the shopper came from.
            onContinueShopping: () {
              if (context.canPop()) context.pop();
            },
          );
        },
        error: (error, _) {
          ref.read(productBuyNowProvider.notifier).state = false;
          AppToast.showError(context, error.toString());
        },
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            flex: 2,
            child: PrimaryAppPrefixIconButton(
              isLoading: isAddingToCart,
              onTap: () {
                final int productQuantity = ref.read(productQuantityProvider);
                ref
                    .read(updateCartProductProvider(productId).notifier)
                    .addToCart(
                      productQuantity,
                      options: productOptions.toBody(),
                    );
              },
              title: LangKeys.addToCartKey.tr(),
              buttonPadding: 10,
              buttonRadius: 8,
              prefixIcon: ReverseWidget(
                child: Assets.media.images.svg.shoppingCartIcon.svg(
                  width: 20,
                  colorFilter: ColorFilter.mode(colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          Expanded(
            child: UnPrimaryAppButton(
              isLoading: isBuyNowLoading,
              title: LangKeys.buyNowKey.tr(),
              buttonPadding: 10,
              onTap: () {
                final int productQuantity = ref.read(productQuantityProvider);
                ref.read(productBuyNowProvider.notifier).state = true;
                ref
                    .read(updateCartProductProvider(productId).notifier)
                    .addToCart(
                      productQuantity,
                      options: productOptions.toBody(),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
