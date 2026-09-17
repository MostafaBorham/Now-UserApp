import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_options_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_action_buttons.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_basic_specifications_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_discount_ticket.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_key_features_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_colors_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_main_info_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_size_selector.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_product_details_vm.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productSlug});
  final String productSlug;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
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
        bodyPadding: const EdgeInsets.only(bottom: 20),
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
              final int? productId = product.id;
              if (productId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ref
                      .read(productOptionsProvider(productId).notifier)
                      .seedDefaults(product);
                });
              }
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 57),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        spacing: 16,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              spacing: 16,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (product.activeDeal != null &&
                                        (product.activeDeal!.discountValue ??
                                                0) >
                                            0)
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
                                          placeholderType:
                                              LoadingViewTypes.circular,
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
                                  isTrusted: false,
                                ),
                                if (product.colors?.isNotEmpty ?? false)
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: ProductColorsSelector(
                                      colors: product.colors!,
                                      onColorSelected: productId == null
                                          ? null
                                          : (color) => ref
                                                .read(
                                                  productOptionsProvider(
                                                    productId,
                                                  ).notifier,
                                                )
                                                .selectColor(color.hex),
                                    ),
                                  ),
                                ...(product.attributes ?? [])
                                    .where(
                                      (attribute) =>
                                          attribute.values?.isNotEmpty ?? false,
                                    )
                                    .map(
                                      (attribute) => Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: ProductSizeSelector(
                                          attribute: attribute,
                                          onValueSelected:
                                              (productId == null ||
                                                  attribute.attributeId == null)
                                              ? null
                                              : (value) {
                                                  if (value.id == null) return;
                                                  ref
                                                      .read(
                                                        productOptionsProvider(
                                                          productId,
                                                        ).notifier,
                                                      )
                                                      .selectAttributeValue(
                                                        attribute.attributeId!,
                                                        value.id!,
                                                      );
                                                },
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
                              ],
                            ),
                          ),
                          if ((product.stock ?? 1) >= 1)
                            Container(
                              color: colors.neutral500.withValues(alpha: 0.3),
                              width: double.infinity,
                              height: 1,
                            ),
                          if ((product.stock ?? 1) >= 1 && product.id != null)
                            ProductActionButtons(
                              productId: product.id!,
                              productName: context.getLocalizedApiText(
                                product.name,
                              ),
                              productImageUrl:
                                  (product.images?.isNotEmpty ?? false)
                                  ? product.images!.first
                                  : '',
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
        onCartTap: () {
          ref.read(mainTabIndexProvider.notifier).state = 2;
          final GoRouter router = GoRouter.of(context);
          while (router.canPop()) {
            router.pop();
          }
        },
      ),
    );
  }
}
