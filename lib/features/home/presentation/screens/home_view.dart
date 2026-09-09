import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
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
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

/// The Home tab.
///
/// The `/api/v1/home-sections` feed drives only the sections wired so far —
/// the `categories` carousel (via [HomeHeaderView.showCategories]),
/// `featured_offers` ([HomeOffersSectionView]), `top_banner`
/// ([HomeTopBannerSectionView]) and `featured_stores`
/// ([HomeFeaturedStoresView]). **Every other section below is
/// still a hardcoded placeholder** (marked `// NOT LINKED` below), kept on
/// screen so their backend wiring can be verified and swapped in one by one as
/// each `/home-sections` type is finished. To wire one: replace its placeholder
/// widget with data pulled from the matching feed section (see how
/// `featured_offers` is read via [_findSection]).
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

  /// The rendered height of the pinned search bar, published so the All Stores
  /// tab bar can pin directly beneath it. Measured once, the first time the bar
  /// is shown (its height is constant afterwards).
  final GlobalKey _pinnedBarKey = GlobalKey();
  final ValueNotifier<double> _searchBarHeight = ValueNotifier<double>(0);

  /// Drives the primary curtain that drops in behind the pinned search field.
  /// Forwards when the field pins, reverses when it un-pins.
  late final AnimationController _dropController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _drop = CurvedAnimation(
    parent: _dropController,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  /// Scroll offset at which the header search field's top reaches just below
  /// the status bar. Resolved lazily from the field's render box, then cached.
  double? _pinThreshold;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch the feed once (the tab is kept alive). Deferred to a post-frame so
    // `context.locale` is available; skipped if the shared provider already
    // holds a value (e.g. after a hot reload).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(getHomeSectionsProvider).hasValue) _loadFeed();
    });
  }

  void _loadFeed() {
    ref
        .read(getHomeSectionsProvider.notifier)
        .getHomeSections(
          platform: Platform.isIOS ? 'ios' : 'android',
          lang: context.locale.languageCode,
        );
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
    // Small hysteresis band so tiny jitters around the threshold don't flicker.
    final bool shouldPin = _pinned.value
        ? _scrollController.offset >= threshold - 8
        : _scrollController.offset >= threshold;
    if (shouldPin != _pinned.value) {
      _pinned.value = shouldPin;
      // Pin: the field stops at the top, then the curtain drops in behind it.
      // Un-pin: snap the pinned bar away at once so the in-flow header field
      // takes over seamlessly. Animating the retract instead leaves the pinned
      // field on screen for the whole reverse while the header field has already
      // rejoined the flow — the user momentarily sees two search fields.
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
    // Offset that scrolls the field's leading edge to the viewport top, minus
    // the status-bar inset so it lands where the pinned bar's SafeArea sits.
    final double reveal = RenderAbstractViewport.of(
      box,
    ).getOffsetToReveal(box, 0.0).offset;
    final double topInset = MediaQuery.paddingOf(context).top;
    _pinThreshold = (reveal - topInset).clamp(0.0, double.infinity);
    return _pinThreshold;
  }

  /// The first feed section of [type], or null when the feed has none.
  HomeSectionModel? _findSection(List<HomeSectionModel> sections, String type) {
    for (final HomeSectionModel section in sections) {
      if (section.type == type) return section;
    }
    return null;
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

    // --- Wired sections (driven by /api/v1/home-sections) ---
    // Keep the carousel visible while loading; hide it only once loaded data
    // has no `categories` section.
    final bool showCategories =
        !feed.hasValue ||
        sections.any((HomeSectionModel s) => s.type == 'categories');
    final HomeSectionModel? offersSection = _findSection(
      sections,
      'featured_offers',
    );
    // Gate the top banner on the feed's presence-only `top_banner` section;
    // false until the feed loads, so nothing flashes before it is known.
    final bool showTopBanner = sections.any(
      (HomeSectionModel s) => s.type == 'top_banner',
    );
    final HomeSectionModel? featuredStoresSection = _findSection(
      sections,
      'featured_stores',
    );

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            spacing: 24,
            children: <Widget>[
              // LINKED — categories carousel gated by the feed.
              HomeHeaderView(
                searchFieldKey: _searchFieldKey,
                showCategories: showCategories,
              ),
              // LINKED — real featured_offers (only shown when the feed has any).
              if (offersSection != null && offersSection.offers.isNotEmpty)
                HomeOffersSectionView(
                  title: offersSection.title,
                  offers: offersSection.offers,
                ),
              // LINKED — top banner carousel, gated by the feed's `top_banner`
              // section; content from /api/v1/banners?type=header_main_page.
              if (showTopBanner) const HomeTopBannerSectionView(),
              // ---- From here down, everything marked NOT LINKED is still a
              //      hardcoded placeholder. Swap each for feed data as its
              //      /home-sections type is finished on the backend. ----
              HomeMostPopularBrandsView(), // NOT LINKED (uses /stores/featured)
              // LINKED — real featured_stores, sitting under Top Brands. Each
              // store's products come inline with it, so there is no extra
              // fetch; hidden entirely when the feed has no such section.
              if (featuredStoresSection != null &&
                  featuredStoresSection.stores.isNotEmpty)
                HomeFeaturedStoresView(stores: featuredStoresSection.stores),
              AspectRatio(
                aspectRatio: 1.47,
                child: BestNearbyStoresSection(),
              ), // NOT LINKED
              AspectRatio(
                aspectRatio: 1,
                child: HomeNeverMissOffersSection(),
              ), // NOT LINKED
              2.hSpace,
              AspectRatio(
                aspectRatio: 3.5,
                child: HomeBannerView(),
              ), // NOT LINKED
              HomeAppCategorySectionView(
                categoryModel: const CategoryModel(
                  name: {'en': 'Electronics', 'ar': 'الإلكترونيات'},
                ),
                productModels: const [
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                ],
              ), // NOT LINKED
              HomeAppCategorySectionView(
                categoryModel: const CategoryModel(
                  name: {'en': 'Fashion', 'ar': 'الموضة'},
                ),
                productModels: const [
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                ],
              ), // NOT LINKED
              AspectRatio(
                aspectRatio: 1.1,
                child: HomeAppCategoryWithLogoSectionView(
                  categoryModel: const CategoryModel(
                    name: {'en': 'Perfume', 'ar': 'عطور '},
                  ),
                  productModels: const [
                    ProductModel(),
                    ProductModel(),
                    ProductModel(),
                    ProductModel(),
                    ProductModel(),
                  ],
                ),
              ), // NOT LINKED
              HomeAppCategorySectionView(
                categoryModel: const CategoryModel(
                  name: {'en': 'Vegetables', 'ar': 'الخضروات'},
                ),
                productModels: const [
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                  ProductModel(),
                ],
              ), // NOT LINKED
              AspectRatio(
                aspectRatio: 3.5,
                child: HomeBannerView(),
              ), // NOT LINKED
              HomeAllStoresSectionView(
                pinTop: _searchBarHeight,
              ), // NOT LINKED (uses /categories + /category stores)

              if (feed.hasError) _FeedErrorRetry(onRetry: _loadFeed),
            ],
          ),
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
      ],
    );
  }
}

/// Compact retry shown when the feed fails to load; the header (and every
/// placeholder section) still renders above it.
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
