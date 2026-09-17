import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/connectivity_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_all_stores_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_with_logo_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_banner_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_featured_stores_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_header_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_most_popular_brands_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_offers_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_pinned_search_bar.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_banner_section_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_header_banners_vm.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';


















class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _searchFieldKey = GlobalKey();
  final ValueNotifier<bool> _pinned = ValueNotifier<bool>(false);




  final GlobalKey _pinnedBarKey = GlobalKey();
  final ValueNotifier<double> _searchBarHeight = ValueNotifier<double>(0);



  late final AnimationController _dropController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _drop = CurvedAnimation(
    parent: _dropController,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );



  double? _pinThreshold;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);



    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(getHomeSectionsProvider).hasValue) _loadFeed();
    });
  }

  void _loadFeed() {






    final bool isGuest =
        ref.read(authSessionProvider).sessionType == SessionType.guest;
    final AddressModel? location = isGuest
        ? CurrentLocationCacheService().getCurrentLocation()
        : null;

    ref
        .read(getHomeSectionsProvider.notifier)
        .getHomeSections(
          platform: Platform.isIOS ? 'ios' : 'android',
          lang: context.locale.languageCode,
          lat: double.tryParse(location?.latitude ?? ''),
          lng: double.tryParse(location?.longitude ?? ''),
        );
  }




  void _refreshHome() {
    _loadFeed();
    ref.read(getHeaderBannersProvider.notifier).getHeaderBanners();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _dropController.dispose();
    _pinned.dispose();
    _searchBarHeight.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double? threshold = _resolveThreshold();
    if (threshold == null) return;

    final bool shouldPin = _pinned.value
        ? _scrollController.offset >= threshold - 8
        : _scrollController.offset >= threshold;
    if (shouldPin != _pinned.value) {
      _pinned.value = shouldPin;





      if (shouldPin) {
        _dropController.forward();
      } else {
        _dropController.value = 0;
      }
    }
  }

  double? _resolveThreshold() {
    if (_pinThreshold != null) return _pinThreshold;
    final RenderObject? box = _searchFieldKey.currentContext
        ?.findRenderObject();
    if (box == null || !box.attached) return null;


    final double reveal = RenderAbstractViewport.of(
      box,
    ).getOffsetToReveal(box, 0.0).offset;
    final double topInset = MediaQuery.paddingOf(context).top;
    _pinThreshold = (reveal - topInset).clamp(0.0, double.infinity);
    return _pinThreshold;
  }


  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<HomeSectionModel>> feed = ref.watch(
      getHomeSectionsProvider,
    );
    final List<HomeSectionModel> sections = feed.maybeWhen(
      data: (List<HomeSectionModel> data) => data,
      orElse: () => const <HomeSectionModel>[],
    );





    final bool isConnected = ref.watch(isConnectedProvider).valueOrNull ?? true;


    ref.listen<AsyncValue<bool>>(isConnectedProvider, (
      AsyncValue<bool>? previous,
      AsyncValue<bool> next,
    ) {



      if (previous?.valueOrNull == false && next.valueOrNull == true) {
        _refreshHome();
      }
    });
    // Re-fetch when the signed-in user changes. The feed is session-scoped —
    // every product and store in it carries that user's `cart_quantity` and
    // `is_favourite`, and `_loadFeed` even sends a different location for a
    // guest — so it is invalidated on logout and login alike.
    //
    // Reloading has to be driven from here: the fetch needs a `BuildContext`
    // for the locale, so the session orchestrator cannot kick it off the way it
    // does the other dependencies. Without this the tab survives a login
    // (the OTP screen pops back to a still-mounted shell), `initState` never
    // runs again, and its "fetch only when empty" guard would leave the feed
    // stranded on its shimmer.
    ref.listen<SessionType>(authSessionProvider.select((s) => s.sessionType), (
      SessionType? previous,
      SessionType next,
    ) {
      if (previous != null && previous != next) _loadFeed();
    });
    // Only cue when there is content to show (cached or live); with no cache the
    // feed errors and the existing _FeedErrorRetry covers it instead.
    final bool showSavedContentCue = !isConnected && feed.hasValue;




    final Map<String, HomeSectionModel> byType = <String, HomeSectionModel>{};
    final List<HomeSectionModel> categorySections = <HomeSectionModel>[];
    for (final HomeSectionModel section in sections) {
      final String type = section.type;
      if (type == 'products_by_category') {
        categorySections.add(section);
      } else {
        byType[type] = section;
      }
    }

    final bool showCategories =
        !feed.hasValue || byType.containsKey('categories');
    final HomeSectionModel? offersSection = byType['featured_offers'];
    final bool showTopBanner = byType.containsKey('top_banner');
    final HomeSectionModel? featuredStoresSection = byType['featured_stores'];
    final HomeSectionModel? nearbyStoresSection = byType['nearby_stores'];
    final HomeSectionModel? flashOffersSection = byType['flash_offers'];
    final HomeSectionModel? middlePromoSection = byType['promo_block_middle'];
    final HomeSectionModel? footerPromoSection = byType['promo_block_footer'];
    final HomeSectionModel? allStoresSection = byType['all_stores'];

    final List<Widget> feedChildren = <Widget>[
      HomeHeaderView(
        searchFieldKey: _searchFieldKey,
        showCategories: showCategories,
      ),
      if (offersSection != null && offersSection.offers.isNotEmpty)
        HomeOffersSectionView(
          title: offersSection.title,
          offers: offersSection.offers,
        ),
      if (showTopBanner) const HomeTopBannerSectionView(),
      const HomeMostPopularBrandsView(),
      if (featuredStoresSection != null &&
          featuredStoresSection.stores.isNotEmpty)
        HomeFeaturedStoresView(stores: featuredStoresSection.stores),
      if (nearbyStoresSection != null && nearbyStoresSection.stores.isNotEmpty)
        AspectRatio(
          aspectRatio: 1.47,
          child: BestNearbyStoresSection(
            title: nearbyStoresSection.title,
            stores: nearbyStoresSection.stores,
          ),
        ),
      if (flashOffersSection != null && flashOffersSection.products.isNotEmpty)
        AspectRatio(
          aspectRatio: 1,
          child: HomeNeverMissOffersSection(
            products: flashOffersSection.products,
            backgroundColor: flashOffersSection.backgroundColor,
            viewAllTextColor: flashOffersSection.viewAllTextColor,
            viewAllUnderlineColor: flashOffersSection.viewAllUnderlineColor,
          ),
        ),
      if (middlePromoSection != null && middlePromoSection.banners.isNotEmpty)
        AspectRatio(
          aspectRatio: 3.5,
          child: HomeBannerView(banner: middlePromoSection.banners.first),
        ),
      for (final HomeSectionModel section in categorySections)
        if (section.products.isNotEmpty)
          _ProductsByCategorySection(section: section),
      if (footerPromoSection != null && footerPromoSection.banners.isNotEmpty)
        AspectRatio(
          aspectRatio: 3.5,
          child: HomeBannerView(banner: footerPromoSection.banners.first),
        ),
      if (allStoresSection != null)
        HomeAllStoresSectionView(
          pinTop: _searchBarHeight,
          stores: allStoresSection.stores,
        ),
      if (feed.hasError) _FeedErrorRetry(onRetry: _loadFeed),
    ];

    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.only(bottom: showSavedContentCue ? 52 : 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => index.isOdd
                      ? const SizedBox(height: 24)
                      : feedChildren[index ~/ 2],
                  childCount: feedChildren.isEmpty
                      ? 0
                      : feedChildren.length * 2 - 1,
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_pinned, _dropController]),
            builder: (context, _) {
              if (!_pinned.value && _dropController.value == 0) {
                return const SizedBox.shrink();
              }
              if (_searchBarHeight.value == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final RenderObject? box = _pinnedBarKey.currentContext
                      ?.findRenderObject();
                  if (box is RenderBox && box.hasSize) {
                    _searchBarHeight.value = box.size.height;
                  }
                });
              }
              return HomePinnedSearchBar(
                key: _pinnedBarKey,
                progress: _drop.value,
                onTap: () => context.pushNamed(AppRoutes.searchScreen),
              );
            },
          ),
        ),




        if (showSavedContentCue)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OfflineSavedContentCue(onRetry: _refreshHome),
          ),
      ],
    );
  }
}




class _ProductsByCategorySection extends StatelessWidget {
  const _ProductsByCategorySection({required this.section});

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context) {
    final CategoryModel category = section.category ?? const CategoryModel();

    if (section.displayDesign == 'color_with_image') {

      return HomeAppCategoryWithLogoSectionView(
        categoryModel: category,
        productModels: section.products,
        imageUrl: context.getLocalizedApiText(section.media),
        primaryColor: section.primaryColor,
        textColor: section.textColor,
        showViewAll: section.showViewAll,
      );
    }

    return HomeAppCategorySectionView(
      categoryModel: category,
      productModels: section.products,
      primaryColor: section.primaryColor,
      textColor: section.textColor,
      showViewAll: section.showViewAll,
    );
  }
}





class _OfflineSavedContentCue extends StatelessWidget {
  const _OfflineSavedContentCue({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off_outlined, size: 18, color: colors.neutral500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LangKeys.showingSavedContentKey.tr(),
              style: TextStyle(fontSize: 13, color: colors.neutral500),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              LangKeys.retryKey.tr(),
              style: TextStyle(color: colors.primary500Main),
            ),
          ),
        ],
      ),
    );
  }
}



class _FeedErrorRetry extends StatelessWidget {
  const _FeedErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(LangKeys.retryKey.tr()),
        ),
      ),
    );
  }
}
