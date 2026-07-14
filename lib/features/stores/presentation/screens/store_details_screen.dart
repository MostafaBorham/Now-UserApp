import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_app_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_banner.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brand_info_card.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brands_slider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_info_header.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_details_vm.dart';

class StoreDetailsScreen extends ConsumerWidget {
  const StoreDetailsScreen({super.key, required this.storeId});
  final int storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final storeDetailsState = ref.watch(getStoreDetailsProvider(storeId));
    return ProviderScope(
      overrides: [storeProvider.overrideWithValue(StoreModel(id: storeId))],
      child: Scaffold(
        body: AppWavedScaffold(
          body: Column(
            spacing: 16,
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: StoreDetailsInfoHeader(),
              ),
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Container(
                        color: colors.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        width: double.infinity,
                        child: Column(
                          spacing: 15,
                          children: [
                            AppSlider(
                              sliderItems: [StoreDetailsBanner()],
                              itemAspectRatio: 2.8,
                            ),
                            StoreDetailsBrandsSlider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
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
                      unSelectedTabColor: colors.inversePrimary.withValues(
                        alpha: 0.2,
                      ),
                      selectedLabelColor: colors.onPrimary,
                      unSelectedLabelColor: colors.onSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          appBarTitle: LangKeys.storeKey.tr(),
          hasCartIcon: true,
          bodyPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
