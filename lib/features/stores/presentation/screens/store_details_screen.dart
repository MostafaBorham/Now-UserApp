import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_banner.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/unique_store_products_slider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_info_header.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_details_vm.dart';

class StoreDetailsScreen extends ConsumerStatefulWidget {
  const StoreDetailsScreen({super.key, required this.storeId, this.storeName});

  /// `null` when the caller had no store to open — the screen then shows its
  /// "store unavailable" state instead of fetching.
  final int? storeId;

  /// Localized name passed from the tapped store, shown in the app bar while
  /// the details are loading and replaced by the fetched name on response.
  final Map<String, dynamic>? storeName;

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
    final int? storeId = widget.storeId;
    // Reached without a store id — a store whose payload carried none, or a
    // caller that pushed the route with no `extra`. There is nothing to fetch
    // and nothing to retry, so the screen says so instead of asking the API
    // for a store it cannot name.
    if (storeId == null) {
      return Scaffold(
        body: AppWavedView(
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: ServerConnectionErrorWidget(
              message: LangKeys.storeUnavailableKey,
            ),
          ),
          appBarTitle: widget.storeName == null
              ? LangKeys.storeKey.tr()
              : context.getLocalizedApiText(widget.storeName),
        ),
      );
    }
    return _buildStore(context, storeId);
  }

  Widget _buildStore(BuildContext context, int storeId) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<StoreModel> storeDetailsState = ref.watch(
      getStoreDetailsProvider(storeId),
    );
    final Map<String, dynamic>? displayName =
        storeDetailsState.valueOrNull?.name ?? widget.storeName;
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
                  .read(getStoreDetailsProvider(storeId).notifier)
                  .getStoreDetails(),
            ),
          ),
          data: (StoreModel store) {
            final List<BannerModel> banners = store.banners ?? const [];
            return SafeArea(
              top: false,
              child: ProviderScope(
                overrides: [storeProvider.overrideWithValue(store)],
                child: AppRefreshIndicator(
                  // A NestedScrollView's top overscroll reaches the indicator
                  // deeper than level 0, so the default predicate would ignore
                  // the gesture and the pull would do nothing.
                  notificationPredicate: (_) => true,
                  // refresh() deliberately does not flip the state back to
                  // loading, so the page stays on screen instead of collapsing
                  // into the shimmer under the spinner.
                  onRefresh: () => ref
                      .read(getStoreDetailsProvider(storeId).notifier)
                      .refresh(),
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
                                spacing: 20,
                                children: [
                                  // Built only when there are banners: an empty
                                  // AppSlider collapses to nothing, but the
                                  // column's 20px gap around it would remain.
                                  if (banners.isNotEmpty)
                                    AppSlider(
                                      sliderItems: banners
                                          .map(
                                            (BannerModel banner) =>
                                                StoreDetailsBanner(
                                                  banner: banner,
                                                ),
                                          )
                                          .toList(),
                                      itemAspectRatio: 3,
                                    ),
                                  UniqueStoreProductsSlider(),
                                  StoreDiscountCouponsList(),
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: StoreCategoryCirclesList(),
                                  ),
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
                                      tabs: ProductFilters.values
                                          .map(
                                            (ProductFilters filter) =>
                                                filter.label,
                                          )
                                          .toList(),
                                      views: ProductFilters.values
                                          .map(
                                            (ProductFilters filter) =>
                                                StoreDetailsProductsView(
                                                  storeId: storeId,
                                                  filter: filter,
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
        appBarTitle: displayName == null
            ? LangKeys.storeKey.tr()
            : context.getLocalizedApiText(displayName),
        hasCartIcon: true,
        actions: [
          storeDetailsState.when(
            loading: () => AppShimmer(
              child: CircleAvatar(
                radius: MediaQuery.sizeOf(context).width * 0.05,
                backgroundColor: colors.white,
              ),
            ),
            error: (Object error, StackTrace stackTrace) =>
                const SizedBox.shrink(),
            data: (StoreModel store) => CircularAppFavouriteIcon(
              size: MediaQuery.sizeOf(context).width * 0.05,
              elevation: 0,
              backgroundColor: colors.white,
              favouriteType: FavouriteType.store,
              itemId: store.id,
              isFavourite: store.isFavorite ?? false,
            ),
          ),
        ],
        // Tapping the cart drops every route pushed on top of the main screen
        // (store details and anything in between) and switches the main screen's
        // bottom nav to the cart tab (index 2) instead of pushing a new cart
        // route on top of the store details stack.
        onCartTap: () {
          ref.read(mainTabIndexProvider.notifier).state = 2;
          // Capture the router once: after the first pop this widget's context is
          // defunct, so drive the loop off the router instance, not context.
          final GoRouter router = GoRouter.of(context);
          while (router.canPop()) {
            router.pop();
          }
        },
        bodyPadding: EdgeInsets.zero,
      ),
    );
  }
}
