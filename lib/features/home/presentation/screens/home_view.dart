import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_all_stores_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_with_logo_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_banner_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_header_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_most_popular_brands_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_offers_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_pinned_search_bar.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_categories_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
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
      // Pin: the field stops at the top, then the curtain drops behind it.
      // Un-pin: the curtain retracts before the field rejoins the flow.
      shouldPin ? _dropController.forward() : _dropController.reverse();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            spacing: 24,
            children: [
              HomeHeaderView(searchFieldKey: _searchFieldKey),
              HomeOffersSectionView(),
              HomeMostPopularBrandsView(),
              HomeTopCategoriesView(),
              AspectRatio(aspectRatio: 1.47, child: BestNearbyStoresSection()),
              AspectRatio(aspectRatio: 1, child: HomeNeverMissOffersSection()),
              2.hSpace,
              AspectRatio(aspectRatio: 3.5, child: HomeBannerView()),
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
              ),
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
              ),
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
              ),
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
              ),
              AspectRatio(aspectRatio: 3.5, child: HomeBannerView()),
              HomeAllStoresSectionView(pinTop: _searchBarHeight),
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
              // Stay mounted while the curtain retracts, so un-pinning animates.
              if (!_pinned.value && _dropController.value == 0) {
                return const SizedBox.shrink();
              }
              // Publish the bar's height once so the tab bar can pin below it.
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
