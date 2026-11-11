import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_buy_now_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/products/presentation/controllers/product_details_controller.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_options_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_bottom_bar.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_basic_specifications_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_top_bar/product_details_top_bar.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_images_header.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_images_slider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_expansion_sliver.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_viewport.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_key_features_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_colors_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_main_info_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/most_likely_products_section.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_reviews_view/product_reviews_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_size_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_store_info_view/product_store_info_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_product_details_vm.dart';

/// Shared details view; each pager page owns its quantity, options and scroll.
class ProductDetailsBody extends StatelessWidget {
  const ProductDetailsBody({
    super.key,
    required this.productSlug,
    this.topPadding = 16,
    this.showCloseButton = false,
    this.expansionScrollExtent = 0,
    this.imageViewportSize,
  });
  final String productSlug;
  final double topPadding;
  final bool showCloseButton;
  final double expansionScrollExtent;
  final Size? imageViewportSize;

  @override
  Widget build(BuildContext context) => ProviderScope(
    key: ValueKey(productSlug),
    overrides: [
      productQuantityProvider.overrideWith((ref) => 1),
      productBuyNowProvider.overrideWith((ref) => false),
      productOptionsProvider.overrideWith(
        (ref, productId) => ProductOptionsNotifier(),
      ),
    ],
    child: _ProductDetailsContent(
      productSlug: productSlug,
      showCloseButton: showCloseButton,
      expansionScrollExtent: expansionScrollExtent,
      imageViewportSize: imageViewportSize,
    ),
  );
}

class _ProductDetailsContent extends ConsumerStatefulWidget {
  const _ProductDetailsContent({
    required this.productSlug,
    required this.showCloseButton,
    required this.expansionScrollExtent,
    required this.imageViewportSize,
  });
  final bool showCloseButton;
  final String productSlug;
  final double expansionScrollExtent;
  final Size? imageViewportSize;

  @override
  ConsumerState<_ProductDetailsContent> createState() =>
      _ProductDetailsContentState();
}

class _ProductDetailsContentState extends ConsumerState<_ProductDetailsContent>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final ProductDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProductDetailsController(
      vsync: this,
      expansionScrollExtent: widget.expansionScrollExtent,
    );
  }

  @override
  void didUpdateWidget(covariant _ProductDetailsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.expansionScrollExtent = widget.expansionScrollExtent;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() {
    return ref
        .read(getProductDetailsProvider(widget.productSlug).notifier)
        .getProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final double topBarHeight = safePadding.top + kToolbarHeight;
    final Size imageViewportSize =
        widget.imageViewportSize ?? MediaQuery.sizeOf(context);
    final productDetailsState = ref.watch(
      getProductDetailsProvider(widget.productSlug),
    );
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: productDetailsState.when(
              loading: () => ProductDetailsShimmer(topPadding: topBarHeight),
              error: (Object error, StackTrace stackTrace) =>
                  ServerConnectionErrorWidget(
                    message: error.toString(),
                    onRetry: _fetchProductDetails,
                  ),
              data: (product) {
                final int? productId = product.id;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (productId != null) {
                    ref
                        .read(productOptionsProvider(productId).notifier)
                        .seedDefaults(product);
                  }
                  // Start the stepper at the product's minimum orderable quantity.
                  // Idempotent so pull-to-refresh never drops the shopper's count.
                  final int minQuantity = product.minOrderQuantity ?? 1;
                  if (ref.read(productQuantityProvider) < minQuantity) {
                    ref.read(productQuantityProvider.notifier).state =
                        minQuantity;
                  }
                });
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
                  child: Column(
                    children: [
                      Expanded(
                        child: AppRefreshIndicator(
                          edgeOffset: topBarHeight,
                          onRefresh: () async => _fetchProductDetails(),
                          child: NotificationListener<ScrollMetricsNotification>(
                            onNotification: _controller.onScrollMetricsChanged,
                            child: CustomScrollView(
                              controller: _controller.scrollController,
                              physics: ProductDetailsScrollPhysics(
                                viewportScale: ProductDetailsViewport.scaleOf(
                                  context,
                                ),
                                parent: const AlwaysScrollableScrollPhysics(),
                              ),
                              slivers: [
                                ProductExpansionSliver(
                                  extent: widget.expansionScrollExtent,
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  sliver: SliverToBoxAdapter(
                                    child: Column(
                                      spacing: 16,
                                      children: [
                                        ProductImagesHeader(
                                          viewportSize: imageViewportSize,
                                          topPadding: topBarHeight,
                                          fadeProgress: _controller.pinProgress,
                                          child: ProductImagesSlider(
                                            images: product.images,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Column(
                                            spacing: 16,
                                            children: [
                                              ProductMainInfoCard(
                                                productNameKey:
                                                    _controller.productNameKey,
                                                titleProgress:
                                                    _controller.titleProgress,
                                              ),
                                              if (product.colors?.isNotEmpty ??
                                                  false)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerStart,
                                                  child: ProductColorsSelector(
                                                    colors: product.colors!,
                                                    onColorSelected:
                                                        productId == null
                                                        ? null
                                                        : (color) => ref
                                                              .read(
                                                                productOptionsProvider(
                                                                  productId,
                                                                ).notifier,
                                                              )
                                                              .selectColor(
                                                                color.hex,
                                                              ),
                                                  ),
                                                ),
                                              ...(product.attributes ?? [])
                                                  .where(
                                                    (attribute) =>
                                                        attribute
                                                            .values
                                                            ?.isNotEmpty ??
                                                        false,
                                                  )
                                                  .map(
                                                    (attribute) => Align(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .centerStart,
                                                      child: ProductSizeSelector(
                                                        attribute: attribute,
                                                        onValueSelected:
                                                            (productId ==
                                                                    null ||
                                                                attribute
                                                                        .attributeId ==
                                                                    null)
                                                            ? null
                                                            : (value) {
                                                                if (value.id ==
                                                                    null) {
                                                                  return;
                                                                }
                                                                ref
                                                                    .read(
                                                                      productOptionsProvider(
                                                                        productId,
                                                                      ).notifier,
                                                                    )
                                                                    .selectAttributeValue(
                                                                      attribute
                                                                          .attributeId!,
                                                                      value.id!,
                                                                    );
                                                              },
                                                      ),
                                                    ),
                                                  ),
                                              if (keyFeatures.isNotEmpty)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerStart,
                                                  child: ProductKeyFeaturesView(
                                                    productFeatures:
                                                        keyFeatures,
                                                  ),
                                                ),
                                              if (specifications.isNotEmpty)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerStart,
                                                  child:
                                                      ProductBasicSpecificationsView(
                                                        specifications:
                                                            specifications,
                                                      ),
                                                ),
                                              if (product.vendor != null)
                                                ProductStoreInfoView(
                                                  store: product.vendor!,
                                                  onTap:
                                                      product.vendor!.id == null
                                                      ? null
                                                      : () => context.pushNamed(
                                                          AppRoutes
                                                              .storeDetailsScreen,
                                                          pathParameters:
                                                              <String, String>{
                                                                'id':
                                                                    '${product.vendor!.id}',
                                                              },
                                                          extra: product
                                                              .vendor!
                                                              .name,
                                                        ),
                                                ),
                                              ProductReviewsView(
                                                onViewAllTap: () =>
                                                    context.pushNamed(
                                                      AppRoutes
                                                          .productReviewsScreen,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const MostLikelyProductsSection(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ProductDetailsBottomBar(
                        onQuantityRejected: _fetchProductDetails,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            child: ProductDetailsTopBar(
              showCloseButton: widget.showCloseButton,
              productDetailsState: productDetailsState,
              isProductNamePinned: _controller.isProductNamePinned,
              titleProgress: _controller.titleProgress,
              productNameShift: _controller.productNameShift,
              onCartTap: () {
                ref.read(mainTabIndexProvider.notifier).state = 2;
                final GoRouter router = GoRouter.of(context);
                while (router.canPop()) {
                  router.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
