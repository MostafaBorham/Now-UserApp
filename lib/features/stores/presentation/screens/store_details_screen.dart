import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/white_gradient_overlay_effect.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_arrow_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_app_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_banner.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brand_info_card.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brands_slider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_info_header.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';

class StoreDetailsScreen extends StatelessWidget {
  const StoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.onSecondaryFixed,
      body: SafeArea(
        bottom: false,
        child: Column(
          spacing: 15,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StoreDetailsAppBar(),
            ),
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: StoreDetailsInfoHeader(),
                        ),
                        Container(
                          color: colors.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 16).copyWith(
                            top: 35
                          ),
                          width: double.infinity,
                          child: Column(
                            spacing: 15,
                            children: [
                              AppSlider(sliderItem: StoreDetailsBanner(),itemAspectRatio: 2.8,),
                              StoreDetailsBrandsSlider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: StoreDetailsBrandInfoCard(),
                              ),
                              5.hSpace,
                              StoreDiscountCouponsList(),
                              5.hSpace,
                              StoreCategoryCirclesList(),
                              2.hSpace,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                body: Container(
                  color: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButtonTabBar(
                    tabs: [
                      LangKeys.allKey.tr(),
                      'Devices',
                      'sddssdsd',
                      'aaaaaaa',
                    ],
                    views: [
                      StoreDetailsProductsView(),
                      StoreDetailsProductsView(),
                      StoreDetailsProductsView(),
                      StoreDetailsProductsView(),
                    ],
                    selectedTabColor: colors.tertiaryContainer,
                    unSelectedTabColor: colors.inversePrimary
                        .withValues(alpha: 0.2),
                    selectedLabelColor: colors.onPrimary,
                    unSelectedLabelColor: colors.onSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      /*body: AppWavedScaffold(
        appBarTitle: LangKeys.storesKey.tr(),
        appBarActions: [
          InkWell(
            child: CircleAvatar(
              backgroundColor: colors.onPrimary,
              radius: 20,
              child: Center(
                child: Assets.media.images.svg.shoppingCartIcon
                    .svg(
                    fit: BoxFit.contain,
                    width:20,
                  colorFilter: ColorFilter.mode(colors.onSecondary, BlendMode.srcIn),
                ),
              ),
            ),
          )
        ],
        body: Column(
          children: [
            ClipPath(
              clipper: TopWaveClipper(),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: AppCachedNetworkImage(
                  imageUrl:
                  'https://i.pinimg.com/236x/ea/a7/7c/eaa77cb87594418722bf12af28481fdb.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const StoreFeaturedProductCard(),
            20.hSpace,
            const StoreDiscountCouponsList(),
            20.hSpace,
            const StoreCategoryCirclesList(),
            12.hSpace,
            const StoreProductsFilterBar(),
            16.hSpace,
            const StoreProductsGrid(),
          ],
        ),
      ),*/
    );
  }
}
