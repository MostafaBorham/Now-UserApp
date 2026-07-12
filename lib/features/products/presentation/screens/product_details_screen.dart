import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/placeholder_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_basic_specifications_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_key_features_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_colors_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_main_info_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_size_selector.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_product_details_vm.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productSlug});
  final String productSlug;
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final productDetailsState = ref.watch(getProductDetailsProvider(productSlug));
    return Scaffold(
      body: AppWavedScaffold(
        body: productDetailsState.when(
          loading: () {
            return Center(child: CircularProgressIndicator());
          },
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: () => ref.read(getProductDetailsProvider(productSlug).notifier).getProductDetails(),
              ),
          data: (product) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colors.errorContainer,
                          ),
                          child: Text(
                            '10%',
                            style: AppTextStyles.style14Bold.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                        CircularAppFavouriteIcon(onFavouriteChanged: (p0) {}),
                      ],
                    ),
                    AppSlider(
                      sliderItem: AppCachedNetworkImage(
                        imageUrl:
                        'https://shuttershopegypt.com/wp-content/uploads/2026/01/1727307031_IMG_2344874.webp',
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        placeholderType: PlaceholderTypes.circular,
                        circularProgressSize: 50,
                      ),
                      itemAspectRatio: 1.5,
                    ),
                    ProductMainInfoCard(),
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
                            title: LangKeys.addToCartKey.tr(),
                            buttonPadding: 10,
                            buttonRadius:8,
                            prefixIcon: Assets.media.images.svg.shoppingCartIcon.svg(
                              width: 20,
                              colorFilter: ColorFilter.mode(
                                colors.onPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: UnPrimaryButton(title: 'Buy Now',buttonPadding: 10,)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        appBarTitle: 'Product Details',
        appBarActions: [
          InkWell(
            onTap: () => context.pop(),
            child: CircleAvatar(
              backgroundColor: colors.onPrimary,
              radius: 25,
              child: Center(
                child: Assets.media.images.svg.shoppingCartIcon.svg(
                  fit: BoxFit.contain,
                  width: 25,
                  colorFilter: ColorFilter.mode(
                    colors.onSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
