import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_basic_specifications_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_key_features_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_colors_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_main_info_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_size_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/success_add_to_cart_view.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_product_details_vm.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productSlug});
  final String productSlug;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final productDetailsState = ref.watch(
      getProductDetailsProvider(productSlug),
    );
    return Scaffold(
      body: AppWavedView(
        body: SafeArea(
          child: productDetailsState.when(
            loading: () {
              return ProductDetailsShimmer();
            },
            error: (Object error, StackTrace stackTrace) =>
                ServerConnectionErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref
                      .read(getProductDetailsProvider(productSlug).notifier)
                      .getProductDetails(),
                ),
            data: (product) {
              final productCartQuantity = (product.cartQuantity ?? 0) > 0
                  ? product.cartQuantity!
                  : 1;
              final isAddingToCart = ref
                  .watch(updateCartProductProvider(product.id ?? -1))
                  .isLoading;
              // React to the add-to-cart result: surface failures as a snackbar,
              // and on success reveal the confirmation bottom sheet.
              ref.listen(
                updateCartProductProvider(product.id ?? -1),
                (previous, next) {
                  next.whenOrNull(
                    data: (cart) {
                      if (cart == null) return;
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: colors.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (sheetContext) => SuccessAddToCartView(
                          productName: context.getLocalizedApiText(
                            product.name,
                          ),
                          productImageUrl:
                              (product.images?.isNotEmpty ?? false)
                              ? product.images!.first
                              : '',
                          onViewCart: () {
                            Navigator.of(sheetContext).pop();
                            context.pushNamed(AppRoutes.cartScreen);
                          },
                          onContinueShopping: () {
                            // Close the sheet, then pop the product details
                            // screen to return to the page that opened it.
                            Navigator.of(sheetContext).pop();
                            if (context.canPop()) context.pop();
                          },
                        ),
                      );
                    },
                    error: (error, _) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              error.toString().tr(),
                              style: AppTextStyles.style16SemiBold.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: colors.onError,
                          ),
                        );
                    },
                  );
                },
              );
              return ProviderScope(
                overrides: [productProvider.overrideWithValue(product)],
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ).copyWith(bottom: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: colors.errorContainer,
                              ),
                              child: Text(
                                '${product.activeDeal?.discountValue ?? 0}%',
                                style: AppTextStyles.style14Bold.copyWith(
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                            CircularAppFavouriteIcon(
                              favouriteType: FavouriteType.product,
                              itemId: product.id,
                              isFavourite: product.isFavorite ?? false,
                              onFavouriteChanged: (p0) {},
                            ),
                          ],
                        ),
                        AppSlider(
                          sliderItems: (product.images ?? [])
                              .map(
                                (image) => AppCachedNetworkImage(
                                  imageUrl: image,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  placeholderType: LoadingViewTypes.circular,
                                  circularProgressSize: 50,
                                ),
                              )
                              .toList(),
                          itemAspectRatio: 1.5,
                        ),
                        ProductMainInfoCard(
                          description: context.getLocalizedApiText(
                            product.description,
                          ),
                          storeName: context.getLocalizedApiText(
                            product.vendor?.name,
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ProductColorsSelector(),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ProductSizeSelector(),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ProductKeyFeaturesView(
                            productFeatures: [
                              'The text is an example of text that can be replaced in the same space. This text was generated by a text generator.',
                              'The text is an example of text that can be replaced in the same space. This text was generated by a text generator.',
                              'The text is an example of text that can be replaced in the same space. This text was generated by a text generator.',
                            ],
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ProductBasicSpecificationsView(),
                        ),
                        Container(
                          color: colors.onSurface.withValues(alpha: 0.3),
                          width: double.infinity,
                          height: 1,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              flex: 2,
                              child: PrimaryAppPrefixIconButton(
                                isLoading: isAddingToCart,
                                onTap: () {
                                  final productQuantity = ref.read(
                                    productQuantityProvider,
                                  );
                                  if (product.id != null) {
                                    ref
                                        .read(
                                          updateCartProductProvider(
                                            product.id!,
                                          ).notifier,
                                        )
                                        .addToCart(
                                          productQuantity,
                                        );
                                  }
                                },
                                title: LangKeys.addToCartKey.tr(),
                                buttonPadding: 10,
                                buttonRadius: 8,
                                prefixIcon: Assets
                                    .media
                                    .images
                                    .svg
                                    .shoppingCartIcon
                                    .svg(
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                        colors.onPrimary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                              ),
                            ),
                            Expanded(
                              child: UnPrimaryButton(
                                title: 'Buy Now',
                                buttonPadding: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        appBarTitle: 'Product Details',
        hasCartIcon: true,
      ),
    );
  }
}
