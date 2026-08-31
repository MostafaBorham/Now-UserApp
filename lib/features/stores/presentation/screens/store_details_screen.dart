import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_banner.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brands_slider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_info_header.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_details_vm.dart';

class StoreDetailsScreen extends ConsumerStatefulWidget {
  const StoreDetailsScreen({super.key, required this.storeId});
  final int storeId;

  @override
  ConsumerState<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen> {
  // Wired to both the NestedScrollView (outer position) and AppWavedView so the
  // top wave flattens into a straight edge while scrolled and restores at the
  // top — same behavior as the settings screen.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<StoreModel> storeDetailsState = ref.watch(
      getStoreDetailsProvider(widget.storeId),
    );
    return Scaffold(
      body: AppWavedView(
        scrollController: _scrollController,
        body: storeDetailsState.when(
          loading: () => const StoreDetailsShimmer(),
          error: (Object error, StackTrace stackTrace) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ServerConnectionErrorWidget(
              message: error.toString(),
              onRetry: () => ref
                  .read(getStoreDetailsProvider(widget.storeId).notifier)
                  .getStoreDetails(),
            ),
          ),
          data: (StoreModel store) {
            final List<ProductModel> products = store.products ?? const [];
            return SafeArea(
              top: false,
              child: ProviderScope(
                overrides: [storeProvider.overrideWithValue(store)],
                child: AppRefreshIndicator(
                  onRefresh: () => ref
                      .read(getStoreDetailsProvider(widget.storeId).notifier)
                      .getStoreDetails(),
                  child: NestedScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Header + banners scroll away with the content; only the
                    // CustomButtonTabBar (the NestedScrollView body) stays
                    // pinned to the top while the product grid scrolls.
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 390 / 240,
                              child: StoreDetailsInfoHeader(),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              color: colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              width: double.infinity,
                              child: Column(
                                spacing: 15,
                                children: [
                                  AppSlider(
                                    sliderItems: (store.banners ?? const [])
                                        .map(
                                          (BannerModel banner) =>
                                              StoreDetailsBanner(
                                                banner: banner,
                                              ),
                                        )
                                        .toList(),
                                    itemAspectRatio: 3,
                                  ),
                                  StoreDetailsBrandsSlider(),
                                  StoreDiscountCouponsList(),
                                  StoreCategoryCirclesList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    body: Container(
                      color: colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              const double minTabBarHeight = 70;
                              return ClipRect(
                                child: OverflowBox(
                                  alignment: AlignmentDirectional.topStart,
                                  minHeight: 0,
                                  maxHeight: double.infinity,
                                  child: SizedBox(
                                    height:
                                        constraints.maxHeight < minTabBarHeight
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
                                            (
                                              StoresSortType sortType,
                                            ) => StoreDetailsProductsView(
                                              products: products,
                                              sortType: sortType,
                                              onProductFavouriteChanged:
                                                  (
                                                    int? productId,
                                                    bool isFavourite,
                                                  ) => ref
                                                      .read(
                                                        getStoreDetailsProvider(
                                                          widget.storeId,
                                                        ).notifier,
                                                      )
                                                      .updateProductFavourite(
                                                        productId,
                                                        isFavourite,
                                                      ),
                                            ),
                                          )
                                          .toList(),
                                      // selectedTabColor: colors.tertiaryContainer,
                                      unSelectedTabColor: colors.neutral400
                                          .withValues(alpha: 0.2),
                                      selectedLabelColor: colors.white,
                                      unSelectedLabelColor: colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                  ),
                ),
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
