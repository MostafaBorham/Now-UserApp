import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/current_location_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/connectivity_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/utils/open_category.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_all_stores_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_with_logo_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_banner_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_featured_stores_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_header_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_live_orders_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_most_popular_brands_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_special_offers_section_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/notifications/order_tracking_notification.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_live_orders_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  static const double _pinnedBarBottomGap = 12;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _searchFieldKey = GlobalKey();
  final GlobalKey _overlayFieldKey = GlobalKey();
  final ValueNotifier<bool> _pinned = ValueNotifier<bool>(false);

  final ValueNotifier<double> _fieldTop = ValueNotifier<double>(-1);
  final ValueNotifier<double> _fieldHeight = ValueNotifier<double>(0);
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

  double? _anchor;

  /// A feed load waiting for the location pass in flight to settle: the first
  /// load (the splash no longer waits for the launch pass), or a session change
  /// and the re-check it started, so the two trigger one reload instead of two
  /// (BUG-003, QA V2).
  bool _reloadAfterLocation = false;

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _recheckLocation();
        _openTappedOrder();
      },
      // Back from the background: pick up what the admin changed meanwhile
      // (sections, their order, offers, brands) without a restart (BUG-022).
      // The loaded feed stays on screen while it reloads.
      onShow: _refreshAll,
    );
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(getHomeSectionsProvider).hasValue) {
        // Its nearby stores need the fresh fix: the feed holds its skeleton
        // until then rather than loading twice.
        if (ref.read(currentLocationProvider) ==
            CurrentLocationStatus.resolving) {
          _reloadAfterLocation = true;
        } else {
          _loadFeed();
        }
      }
      _onScroll();
      _openTappedOrder();
    });
  }

  /// Track Order for the tray card the app was opened from, if it was: here on
  /// a cold start, on resume when the app was already running.
  Future<void> _openTappedOrder() async {
    final String? uuid = await OrderTrackingNotification.takeTappedOrder();
    if (uuid == null || !mounted) return;
    context.pushNamed(AppRoutes.trackOrderScreen, extra: uuid);
  }

  Future<void> _loadFeed() {
    // Sent for everyone, not just guests. The backend measures nearby stores
    // from a signed-in user's default address when they have one with
    // coordinates, and only otherwise falls back to this pair — which used to
    // be withheld for users, so one without a usable saved address got a feed
    // with no location at all.
    final AddressModel? location = CurrentLocationCacheService()
        .getCurrentLocation();

    return ref
        .read(getHomeSectionsProvider.notifier)
        .getHomeSections(
          platform: Platform.isIOS ? 'ios' : 'android',
          lang: context.locale.languageCode,
          lat: double.tryParse(location?.latitude ?? ''),
          lng: double.tryParse(location?.longitude ?? ''),
        );
  }

  /// Pull-to-refresh and the full-screen retry: the feed and Top Brands. Top
  /// Brands is kept alive, so before this a new brand showed only after the
  /// app was killed (BUG-023, QA V2). Its loaded cards stay on screen while it
  /// reloads; a failed or missing list loads afresh.
  Future<void> _refreshAll() => Future.wait<void>(<Future<void>>[
    _loadFeed(),
    ref.read(getFeaturedStoresProvider.notifier).refresh(),
  ]);

  // The location is otherwise resolved only on the splash, so switching GPS on
  // with the app in the background changed nothing until a cold start. Without
  // a prompt: the user may have just refused one.
  void _recheckLocation() {
    if (CurrentLocationCacheService().getCurrentLocation() != null) return;
    ref.read(currentLocationProvider.notifier).resolve(prompt: false);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _dropController.dispose();
    _pinned.dispose();
    _fieldTop.dispose();
    _fieldHeight.dispose();
    _searchBarHeight.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double? anchor = _resolveAnchor();
    if (anchor == null) return;

    final double topInset = MediaQuery.paddingOf(context).top;
    final double raw = anchor - _scrollController.offset;
    _fieldTop.value = raw < topInset ? topInset : raw;

    final bool shouldPin = _pinned.value
        ? raw <= topInset + 8
        : raw <= topInset;
    if (shouldPin != _pinned.value) {
      _pinned.value = shouldPin;
      shouldPin ? _dropController.forward() : _dropController.reverse();
    }
  }

  double? _resolveAnchor() {
    if (_anchor != null) return _anchor;
    final RenderObject? box = _searchFieldKey.currentContext
        ?.findRenderObject();
    if (box == null || !box.attached) return null;

    return _anchor = RenderAbstractViewport.of(
      box,
    ).getOffsetToReveal(box, 0.0).offset;
  }

  /// The header's top row changed height — a language switch rewraps the
  /// greeting — so the field's slot under it moved with nothing scrolling to
  /// notice. Measured again once this frame's layout is done.
  bool _onHeaderResized(SizeChangedLayoutNotification _) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _anchor = null;
      _onScroll();
    });
    return false;
  }

  void _measureField() {
    final RenderObject? box = _overlayFieldKey.currentContext
        ?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final double height = box.size.height;
    if (height == _fieldHeight.value) return;
    _fieldHeight.value = height;
    _searchBarHeight.value =
        MediaQuery.paddingOf(context).top + height + _pinnedBarBottomGap;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<HomeSectionModel>> feed = ref.watch(
      getHomeSectionsProvider,
    );
    // Whatever is loaded stays on screen while a refresh runs (the view model
    // keeps the previous value), instead of the whole feed flashing back to
    // its shimmer.
    final List<HomeSectionModel> sections =
        feed.valueOrNull ?? const <HomeSectionModel>[];

    final bool isConnected = ref.watch(isConnectedProvider).valueOrNull ?? true;

    ref.listen<AsyncValue<bool>>(isConnectedProvider, (
      AsyncValue<bool>? previous,
      AsyncValue<bool> next,
    ) {
      if (previous?.valueOrNull == false && next.valueOrNull == true) {
        _loadFeed();
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
      if (previous == null || previous == next) return;
      // The session change also re-resolves the location; one reload once that
      // settles serves both.
      if (ref.read(currentLocationProvider) ==
          CurrentLocationStatus.resolving) {
        _reloadAfterLocation = true;
      } else {
        _loadFeed();
      }
    });
    // A location found after the feed loaded (on resume, or after a session
    // change) moves the nearby stores to it; a load waiting for it goes now.
    ref.listen<CurrentLocationStatus>(currentLocationProvider, (
      CurrentLocationStatus? previous,
      CurrentLocationStatus next,
    ) {
      if (previous != CurrentLocationStatus.resolving ||
          next != CurrentLocationStatus.ready) {
        return;
      }
      final bool waited = _reloadAfterLocation;
      _reloadAfterLocation = false;
      if (waited ||
          CurrentLocationCacheService().getCurrentLocation() != null) {
        _loadFeed();
      }
    });
    final bool isUserSession =
        ref.watch(authSessionProvider.select((s) => s.sessionType)) ==
        SessionType.user;
    // Only a bool is watched, so the strip's 10 s refresh rebuilds the strip
    // alone; this flips only when the strip appears or disappears. A guest
    // never watches it, so the poll never starts for them.
    final bool showLiveOrders =
        isUserSession &&
        ref.watch(
          getLiveOrdersProvider.select(
            (s) => s.isLoading || (s.valueOrNull?.isNotEmpty ?? false),
          ),
        );
    // The tray card follows the same poll as the strip, so it too moves only
    // while the app is open. A failed refresh keeps the last value and is not
    // passed on.
    if (isUserSession) {
      ref.listen<AsyncValue<List<OrderModel>>>(getLiveOrdersProvider, (
        AsyncValue<List<OrderModel>>? previous,
        AsyncValue<List<OrderModel>> next,
      ) {
        final List<OrderModel>? live = next.valueOrNull;
        if (live != null) OrderTrackingNotification.sync(context, live);
      });
    }
    // Only cue when there is content to show (cached or live); with no cache the
    // feed errors and the full-size error covers it instead.
    final bool showSavedContentCue = !isConnected && feed.hasValue;

    final Map<String, HomeSectionModel> byType = <String, HomeSectionModel>{
      for (final HomeSectionModel section in sections) section.type: section,
    };

    // The header and top brands render before the feed lands, so special
    // offers holds its slot as a skeleton rather than popping in between them.
    // Only the first load: a refresh keeps the loaded feed, and a failed load
    // shows the retry instead.
    final bool feedFirstLoading = feed.isLoading && !feed.hasValue;
    // Nothing loaded and the load failed (BUG-004, QA V2): one full-size error
    // with a retry replaces the feed. A failed refresh keeps the loaded feed
    // and only adds the small retry at its end.
    final bool feedFailed = feed.hasError && !feed.hasValue && !feed.isLoading;

    final HomeSectionModel? categoriesSection = byType['categories'];
    final bool hasCategories =
        categoriesSection?.categories.isNotEmpty ?? false;
    // Placeholders only while the first load is on its way. A failed load or a
    // loaded section with no items (every category deactivated) hides the
    // carousel: its placeholders looked like a loader that never finished.
    final bool showCategories = feedFirstLoading || hasCategories;
    final HomeSectionModel? offersSection = byType['featured_offers'];
    final List<BannerModel> topBanners =
        byType['top_banner']?.banners ?? const <BannerModel>[];
    final bool hasOffers =
        (offersSection?.offers.isNotEmpty ?? false) || topBanners.isNotEmpty;
    // Top brands hides itself when nothing is featured; the empty state below
    // waits for that, so it never sits under a row of brands.
    final bool noFeaturedStores = ref.watch(
      getFeaturedStoresProvider.select(
        (s) => s.hasValue && s.requireValue.data.isEmpty,
      ),
    );
    final List<HomeFeedSection> feedSections = _feedSections(context, sections);

    // Every section is keyed, so one appearing or disappearing — the
    // live-orders strip collapsing, the feed landing — moves the others
    // instead of tearing down and rebuilding everything after it.
    //
    // Each also names its `content`: the models its child is built from. A
    // section whose content is unchanged keeps the child it built last time,
    // so replacing the feed (every favourite tap does) rebuilds only the
    // sections that hold what changed. Anything a child's constructor reads
    // must be in its content, apart from what never changes here — the keys,
    // the notifiers and this state's own methods.
    final List<HomeFeedSection> feedChildren = <HomeFeedSection>[
      HomeFeedSection(
        key: const ValueKey<String>('header'),
        content: (categoriesSection, showCategories),
        child: NotificationListener<SizeChangedLayoutNotification>(
          onNotification: _onHeaderResized,
          child: HomeHeaderView(
            searchFieldKey: _searchFieldKey,
            searchBarHeight: _fieldHeight,
            showCategories: showCategories,
            categories:
                categoriesSection?.categories ?? const <CategoryModel>[],
          ),
        ),
      ),
      if (showLiveOrders)
        const HomeFeedSection(
          key: ValueKey<String>('live_orders'),
          child: HomeLiveOrdersSectionView(),
        ),
      if (feedFirstLoading || hasOffers)
        HomeFeedSection(
          key: const ValueKey<String>('special_offers'),
          content: (offersSection, byType['top_banner'], feedFirstLoading),
          child: HomeSpecialOffersSectionView(
            offers: offersSection?.offers ?? const <HomeOfferModel>[],
            topBanners: topBanners,
            isLoading: feedFirstLoading,
          ),
        ),
      if (feedFailed)
        HomeFeedSection(
          key: const ValueKey<String>('feed_failed'),
          child: ServerConnectionErrorWidget(
            message: feed.error is String ? feed.error as String : null,
            onRetry: _refreshAll,
          ),
        )
      // With nothing featured the section drew nothing but kept its two
      // 24 dp gaps (QA-030 S5).
      else if (!noFeaturedStores)
        const HomeFeedSection(
          key: ValueKey<String>('top_brands'),
          child: HomeMostPopularBrandsView(),
        ),
      ...feedSections,
      if (feed.hasValue &&
          !hasCategories &&
          !hasOffers &&
          feedSections.isEmpty &&
          noFeaturedStores)
        HomeFeedSection(
          key: const ValueKey<String>('feed_empty'),
          child: NoResultsWidget(emptyMessage: LangKeys.homeFeedEmptyKey.tr()),
        ),
      if (feed.hasError && feed.hasValue)
        HomeFeedSection(
          key: const ValueKey<String>('feed_error'),
          child: _FeedErrorRetry(onRetry: _loadFeed),
        ),
    ];

    return Stack(
      children: <Widget>[
        // Pull-to-refresh: the feed is kept alive and cached, so without this
        // the only ways to refresh it were the offline cue and the error retry.
        AppRefreshIndicator(
          onRefresh: _refreshAll,
          child: CustomScrollView(
            controller: _scrollController,
            // Always scrollable, so a short or empty feed can still be pulled.
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom:
                      (showSavedContentCue ? 52 : 0) +
                      MediaQuery.paddingOf(context).bottom,
                ),
                sliver: HomeFeedList(sections: feedChildren),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _drop,
              builder: (context, _) {
                final double t = _drop.value;
                final double curtainHeight = _searchBarHeight.value;
                if (t == 0 || curtainHeight == 0) {
                  return const SizedBox.shrink();
                }
                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: t,
                    child: SizedBox(
                      width: double.infinity,
                      height: curtainHeight,
                      child: ColoredBox(color: context.colors.primary500Main),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: ValueListenableBuilder<double>(
            valueListenable: _fieldTop,
            builder: (context, fieldTop, child) {
              if (fieldTop < 0) return const SizedBox.shrink();
              if (_fieldHeight.value == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _measureField();
                });
              }
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(top: fieldTop, left: 16, right: 16, child: child!),
                ],
              );
            },
            child: PrimarySearchField(
              key: _overlayFieldKey,
              onTap: () => context.pushNamed(AppRoutes.search2Screen),
            ),
          ),
        ),

        if (showSavedContentCue)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OfflineSavedContentCue(onRetry: _loadFeed),
          ),
      ],
    );
  }

  /// The sections built from the feed's own content, below top brands, in the
  /// order the feed lists them — the admin's order (BUG-007). Empty when the
  /// feed has nothing to show.
  List<HomeFeedSection> _feedSections(
    BuildContext context,
    List<HomeSectionModel> sections,
  ) {
    final Set<ValueKey<Object>> seen = <ValueKey<Object>>{};
    return <HomeFeedSection>[
      for (final HomeSectionModel section in sections)
        if (_feedSectionChild(context, section) case final Widget child)
          // A repeated type without an id would share a key; the first wins.
          if (seen.add(_sectionKey(section)))
            HomeFeedSection(
              key: _sectionKey(section),
              content: section,
              child: child,
            ),
    ];
  }

  /// The widget for one feed-driven section, or null for a type rendered
  /// elsewhere (header, offers) or one with nothing to show.
  Widget? _feedSectionChild(BuildContext context, HomeSectionModel section) {
    return switch (section.type) {
      // The carousel drops stores without products; with none left it
      // drew nothing in a spaced slot (QA-030 S8).
      'featured_stores'
          when section.stores.any(
            (StoreModel store) => store.products?.isNotEmpty ?? false,
          ) =>
        HomeFeaturedStoresView(stores: section.stores),
      'nearby_stores' when section.stores.isNotEmpty => AspectRatio(
        aspectRatio: 1.47,
        child: BestNearbyStoresSection(
          title: section.title,
          stores: section.stores,
        ),
      ),
      'flash_offers' when section.products.isNotEmpty => AspectRatio(
        aspectRatio: 1,
        child: HomeNeverMissOffersSection(
          products: section.products,
          backgroundColor: section.backgroundColor,
          viewAllTextColor: section.viewAllTextColor,
          viewAllUnderlineColor: section.viewAllUnderlineColor,
        ),
      ),
      'promo_block_middle' || 'promo_block_footer'
          when section.banners.isNotEmpty &&
              HomeBannerView.imageUrlFor(context, section.banners.first) !=
                  null =>
        AspectRatio(
          aspectRatio: 3.5,
          child: HomeBannerView(banner: section.banners.first),
        ),
      'products_by_category' when section.products.isNotEmpty =>
        _ProductsByCategorySection(section: section),
      'all_stores' => HomeAllStoresSectionView(
        stores: section.stores,
        itemLimit: section.itemLimit,
        pinTop: _searchBarHeight,
      ),
      _ => null,
    };
  }
}

/// A feed section's key: the backend's section id, unique per feed.
ValueKey<Object> _sectionKey(HomeSectionModel section) =>
    ValueKey<Object>(section.id ?? section.type);

/// The feed's sections, 24 apart. Each is found again by its key when the
/// list changes around it, so an insertion or removal moves the sections after
/// it — with their kept-alive state — instead of rebuilding them at their new
/// index.
@visibleForTesting
class HomeFeedList extends StatelessWidget {
  const HomeFeedList({super.key, required this.sections});

  final List<HomeFeedSection> sections;

  @override
  Widget build(BuildContext context) {
    final Map<Key, int> indexOf = <Key, int>{
      for (int i = 0; i < sections.length; i++) sections[i].key!: i,
    };
    assert(
      indexOf.length == sections.length,
      'Two Home feed sections share a key.',
    );
    return SliverList.separated(
      itemCount: sections.length,
      itemBuilder: (context, index) => sections[index],
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      findItemIndexCallback: (Key key) => indexOf[key],
    );
  }
}

/// Wraps every feed section. It keeps the section alive once built, so
/// scrolling back no longer rebuilds it — the header re-parsed its animated SVG
/// and replayed it on every return to the top, and the horizontal lists lost
/// their positions. And it mutes the section's tickers while it is outside the
/// viewport: a kept-alive or merely cached section would otherwise keep
/// animating (the flash-offer strip, carousel slides, shimmers), and on
/// Impeller every such frame redraws the whole screen. Nests under the tab's
/// own [TickerMode] in the main shell, which still wins.
@visibleForTesting
class HomeFeedSection extends StatefulWidget {
  const HomeFeedSection({super.key, this.content, required this.child});

  /// The data [child] is built from. While it compares equal to the previous
  /// build's, the child built then is kept, so its subtree is not rebuilt;
  /// null always takes the new child. Must hold everything the child's
  /// constructor reads, or the section goes stale.
  final Object? content;

  final Widget child;

  @override
  State<HomeFeedSection> createState() => _HomeFeedSectionState();
}

class _HomeFeedSectionState extends State<HomeFeedSection>
    with AutomaticKeepAliveClientMixin {
  late Widget _child = widget.child;
  Locale? _locale;
  ScrollPosition? _position;
  bool _onScreen = true;
  bool _measureScheduled = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A language switch rebuilds every section whatever its content says:
    // strings built with a context-free `.tr()` would keep the old language.
    final Locale? locale = Localizations.maybeLocaleOf(context);
    if (locale != _locale) {
      _locale = locale;
      _child = widget.child;
    }
    final ScrollPosition? position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_scheduleMeasure);
      _position = position;
      _position?.addListener(_scheduleMeasure);
    }
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(HomeFeedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content == null || widget.content != oldWidget.content) {
      _child = widget.child;
    }
    _scheduleMeasure();
  }

  @override
  void dispose() {
    _position?.removeListener(_scheduleMeasure);
    super.dispose();
  }

  /// Measured after layout, so a section the scroll just moved is judged by
  /// where it is now rather than where it was last frame.
  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (mounted) _measure();
    });
  }

  void _measure() {
    final ScrollPosition? position = _position;
    final RenderObject? box = context.findRenderObject();
    if (position == null ||
        !position.hasViewportDimension ||
        box is! RenderBox ||
        !box.attached ||
        !box.hasSize) {
      return;
    }
    // Same measurement `StickyOnScroll` pins by: the scroll offset that brings
    // this section's top edge to the viewport's.
    final double top =
        RenderAbstractViewport.of(box).getOffsetToReveal(box, 0.0).offset -
        position.pixels;
    final bool onScreen =
        top < position.viewportDimension && top + box.size.height > 0;
    if (onScreen != _onScreen) setState(() => _onScreen = onScreen);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TickerMode(enabled: _onScreen, child: _child);
  }
}

class _ProductsByCategorySection extends ConsumerWidget {
  const _ProductsByCategorySection({required this.section});

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CategoryModel category = section.category ?? const CategoryModel();
    // Read on tap only, so the section watches nothing new.
    void openCategory() => openHomeCategory(
      context,
      ref,
      id: category.id,
      slug: category.slug,
      name: category.name,
    );

    if (section.displayDesign == 'color_with_image') {
      return HomeAppCategoryWithLogoSectionView(
        categoryModel: category,
        productModels: section.products,
        imageUrl: context.getLocalizedApiText(section.media),
        primaryColor: section.primaryColor,
        textColor: section.textColor,
        showViewAll: section.showViewAll,
        onViewAllTap: openCategory,
      );
    }

    return HomeAppCategorySectionView(
      categoryModel: category,
      productModels: section.products,
      primaryColor: section.primaryColor,
      textColor: section.textColor,
      showViewAll: section.showViewAll,
      onViewAllTap: openCategory,
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
