import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';
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
    final AsyncValue<StoreModel> storeDetailsState = ref.watch(
      getStoreDetailsProvider(storeId),
    );
    return Scaffold(
      body: AppWavedView(
        body: storeDetailsState.when(
          loading: () => const StoreDetailsShimmer(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: () => ref
                    .read(getStoreDetailsProvider(storeId).notifier)
                    .getStoreDetails(),
              ),
          data: (StoreModel store) {
            final List<ProductModel> products = store.products ?? const [];
            return ProviderScope(
              overrides: [storeProvider.overrideWithValue(store)],
              child: Column(
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
                                  sliderItems: (store.banners ?? const [])
                                      .map(
                                        (BannerModel banner) =>
                                            StoreDetailsBanner(banner: banner),
                                      )
                                      .toList(),
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
                        child: LayoutBuilder(
                          builder:
                              (
                                BuildContext context,
                                BoxConstraints constraints,
                              ) {
                                const double minTabBarHeight = 70;
                                return ClipRect(
                                  child: OverflowBox(
                                    alignment: AlignmentDirectional.topStart,
                                    minHeight: 0,
                                    maxHeight: double.infinity,
                                    child: SizedBox(
                                      height:
                                          constraints.maxHeight <
                                              minTabBarHeight
                                          ? minTabBarHeight
                                          : constraints.maxHeight,
                                      width: constraints.maxWidth,
                                      child: CustomButtonTabBar(
                                        tabs: StoresSortType.values
                                            .map(
                                              (StoresSortType sortType) =>
                                                  sortType.label.tr(),
                                            )
                                            .toList(),
                                        views: StoresSortType.values
                                            .map(
                                              (StoresSortType sortType) =>
                                                  StoreDetailsProductsView(
                                                    products: products,
                                                    sortType: sortType,
                                                  ),
                                            )
                                            .toList(),
                                        selectedTabColor:
                                            colors.tertiaryContainer,
                                        unSelectedTabColor: colors
                                            .inversePrimary
                                            .withValues(alpha: 0.2),
                                        selectedLabelColor: colors.onPrimary,
                                        unSelectedLabelColor:
                                            colors.onSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        appBarTitle: storeDetailsState.valueOrNull?.name == null
            ? LangKeys.storeKey.tr()
            : context.getLocalizedApiText(storeDetailsState.valueOrNull?.name),
        loadAppBarTitle: storeDetailsState.isLoading,
        hasCartIcon: true,

        bodyPadding: EdgeInsets.zero,
      ),
    );
  }
}
