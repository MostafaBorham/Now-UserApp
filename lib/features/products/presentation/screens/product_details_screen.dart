import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_basic_specifications_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_discount_ticket.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_key_features_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_colors_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_main_info_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_size_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/success_add_to_cart_view.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_product_details_vm.dart';

final _isBuyNowProvider = StateProvider.autoDispose<bool>((ref) => false);

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productSlug});
  final String productSlug;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  // Drives the wave flattening: as the content scrolls up, [AppWavedView]
  // straightens its top wave.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchProductDetails() {
    ref
        .read(getProductDetailsProvider(widget.productSlug).notifier)
        .getProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final productDetailsState = ref.watch(
      getProductDetailsProvider(widget.productSlug),
    );
    return Scaffold(
      body: AppWavedView(
        scrollController: _scrollController,
        body: SafeArea(
          child: productDetailsState.when(
            loading: () {
              return ProductDetailsShimmer();
            },
            error: (Object error, StackTrace stackTrace) =>
                ServerConnectionErrorWidget(
                  message: error.toString(),
                  onRetry: _fetchProductDetails,
                ),
            data: (product) {
              final cartState = ref.watch(updateCartProductProvider(product.id ?? -1));
              final isBuyNow = ref.watch(_isBuyNowProvider);
              final isAddingToCart = cartState.isLoading && !isBuyNow;
              final isBuyNowLoading = cartState.isLoading && isBuyNow;
              ref.listen(updateCartProductProvider(product.id ?? -1), (
                previous,
                next,
              ) {
                next.whenOrNull(
                  data: (cart) {
                    if (cart == null) return;
                    final wasBuyNow = ref.read(_isBuyNowProvider);
                    ref.read(_isBuyNowProvider.notifier).state = false;
                    if (wasBuyNow) {
                      ref.read(mainTabIndexProvider.notifier).state = 2;
                      context.goNamed(AppRoutes.mainScreen);
                      return;
                    }
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (sheetContext) => SuccessAddToCartView(
                        productName: context.getLocalizedApiText(product.name),
                        productImageUrl: (product.images?.isNotEmpty ?? false)
                            ? product.images!.first
                            : '',
                        onViewCart: () {
                          Navigator.of(sheetContext).pop();
                          context.pushNamed(AppRoutes.cartScreen);
                        },
                        onContinueShopping: () {
                          Navigator.of(sheetContext).pop();
                          if (context.canPop()) context.pop();
                        },
                      ),
                    );
                  },
                  error: (error, _) {
                    ref.read(_isBuyNowProvider.notifier).state = false;
                    AppToast.showError(context, error.toString());
                  },
                );
              });
              // Resolve each section's data up front so the section is dropped
              // whenever it has nothing to show — not just when the raw list is
              // null/empty, but also when every entry resolves to blank.
              final List<String> keyFeatures = (product.mainFeatures ?? [])
                  .map((feature) => context.getLocalizedApiText(feature))
                  .where((text) => text.isNotEmpty)
                  .toList();
              final specifications = (product.specifications ?? [])
                  .where(
                    (spec) =>
                        (spec.key?.isNotEmpty ?? false) ||
                        (spec.value?.isNotEmpty ?? false),
                  )
                  .toList();
              return ProviderScope(
                overrides: [productProvider.overrideWithValue(product)],
                child: AppRefreshIndicator(
                  onRefresh: () async => _fetchProductDetails(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    // The wave owns no top spacing once a scroll controller is
                    // wired in, so the content carries it and scrolls up under
                    // the flattening wave.
                    padding: const EdgeInsets.only(top: 57),
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
                              if (product.activeDeal != null &&
                                  (product.activeDeal!.discountValue ?? 0) > 0)
                                ProductDiscountTicket(
                                  deal: product.activeDeal!,
                                )
                              else
                                const SizedBox.shrink(),
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
                          if (product.colors?.isNotEmpty ?? false)
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ProductColorsSelector(
                                colors: product.colors!,
                              ),
                            ),
                          // Every variant attribute (Size, Material, …) becomes
                          // its own labelled selector section.
                          ...(product.attributes ?? [])
                              .where(
                                (attribute) =>
                                    attribute.values?.isNotEmpty ?? false,
                              )
                              .map(
                                (attribute) => Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: ProductSizeSelector(
                                    attribute: attribute,
                                  ),
                                ),
                              ),
                          if (keyFeatures.isNotEmpty)
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ProductKeyFeaturesView(
                                productFeatures: keyFeatures,
                              ),
                            ),
                          if (specifications.isNotEmpty)
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ProductBasicSpecificationsView(
                                specifications: specifications,
                              ),
                            ),
                          Container(
                            color: colors.neutral500.withValues(alpha: 0.3),
                            width: double.infinity,
                            height: 1,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          if ((product.stock ?? 1) >= 1)
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
                                          .addToCart(productQuantity);
                                    }
                                  },
                                  title: LangKeys.addToCartKey.tr(),
                                  buttonPadding: 10,
                                  buttonRadius: 8,
                                  prefixIcon: ReverseWidget(
                                    child: Assets
                                        .media
                                        .images
                                        .svg
                                        .shoppingCartIcon
                                        .svg(
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
                                child: UnPrimaryButton(
                                  isLoading: isBuyNowLoading,
                                  title: LangKeys.buyNowKey.tr(),
                                  buttonPadding: 10,
                                  onTap: () {
                                    final productQuantity = ref.read(
                                      productQuantityProvider,
                                    );
                                    if (product.id != null) {
                                      ref.read(_isBuyNowProvider.notifier).state = true;
                                      ref
                                          .read(
                                            updateCartProductProvider(
                                              product.id!,
                                            ).notifier,
                                          )
                                          .addToCart(productQuantity);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        appBarTitle: LangKeys.productDetailsKey.tr(),
        hasCartIcon: true,
        // Tapping the cart drops every route pushed on top of the main screen
        // (product details and anything in between) and switches the main
        // screen's bottom nav to the cart tab (index 2) instead of pushing a
        // new cart route on top of the product details stack — same behaviour
        // as the store details screen.
        onCartTap: () {
          ref.read(mainTabIndexProvider.notifier).state = 2;
          // Capture the router once: after the first pop this widget's context
          // is defunct, so drive the loop off the router instance, not context.
          final GoRouter router = GoRouter.of(context);
          while (router.canPop()) {
            router.pop();
          }
        },
      ),
    );
  }
}
