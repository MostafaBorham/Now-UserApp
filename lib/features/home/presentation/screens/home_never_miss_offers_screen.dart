import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/products/product_details_list_scope.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/badges/big_discount_badge.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/bottom_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home_never_miss_offers/offers_pattern_background.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_item.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:easy_localization/easy_localization.dart';

/// The feed's `flash_offers` products. The feed sends every product of each
/// offer the section holds, so this is the whole list, not a first page.
List<ProductModel> _offers(AsyncValue<List<HomeSectionModel>> feed) =>
    feed.valueOrNull
        ?.where((HomeSectionModel section) => section.type == 'flash_offers')
        .firstOrNull
        ?.products ??
    const <ProductModel>[];

/// "View all" of Home's never-miss-offers strip: the same products, as a grid.
class HomeNeverMissOffersScreen extends ConsumerStatefulWidget {
  const HomeNeverMissOffersScreen({super.key});

  @override
  ConsumerState<HomeNeverMissOffersScreen> createState() =>
      _HomeNeverMissOffersScreenState();
}

class _HomeNeverMissOffersScreenState
    extends ConsumerState<HomeNeverMissOffersScreen>
    with TickerProviderStateMixin {
  final double _designWidth = 390;
  final double _headerHeight = 202;
  final double _waveHeight = 170;
  final double _logoEnd = 33;
  final double _logoTop = 101;
  final double _logoWidth = 151;
  final double _logoHeight = 100;
  final double _backIconStart = 20;
  final double _backIconSize = 20;
  static const double _backHitPadding = 14;
  final double _headlineTopGap = 6;
  final int _shimmerItemsCount = 6;
  final ScrollController _scrollController = ScrollController();
  Drag? _waveDrag;

  late final AnimationController _introController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..forward();

  late final AnimationController _waveFlattenController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<double> _waveFlatten = CurvedAnimation(
    parent: _waveFlattenController,
    curve: Curves.easeOutCubic,
  );

  late final Animation<double> _headlineOpacity = CurvedAnimation(
    parent: _introController,
    curve: const Interval(0.2, 0.4, curve: Cubic(0, 0, 0.2, 1)),
  );

  late final Animation<Offset> _headlineSlide =
      Tween<Offset>(begin: const Offset(0.14, 0.07), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _introController,
          curve: const Interval(0.2, 0.5, curve: Curves.easeOutQuint),
        ),
      );

  late final Animation<double> _logoOpacity = CurvedAnimation(
    parent: _introController,
    curve: const Interval(0, 0.2, curve: Curves.easeOutQuint),
  );

  late final Animation<double> _logoScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0.3,
        end: 1.05,
      ).chain(CurveTween(curve: Curves.easeOutQuint)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.05,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 10,
    ),
    TweenSequenceItem(tween: ConstantTween<double>(1), weight: 60),
  ]).animate(_introController);

  @override
  void dispose() {
    _waveDrag?.cancel();
    _scrollController.dispose();
    _waveFlattenController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isRTL = context.isRTL;
    // Loading with nothing to show yet. A refresh keeps the loaded offers on
    // screen; the list only empties when a login started from here resets the
    // feed and Home, underneath, fetches it again.
    final bool isLoading = ref.watch(
      getHomeSectionsProvider.select(
        (AsyncValue<List<HomeSectionModel>> state) =>
            state.isLoading && _offers(state).isEmpty,
      ),
    );

    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.purple200,
        body: LayoutBuilder(
          builder: (context, con) {
            final double scale = con.maxWidth / _designWidth;
            final double headerHeight = _headerHeight * scale;
            final double waveHeight = _waveHeight * scale;
            final double logoPinOffset = _logoTop * scale - statusBarHeight;
            final Widget header = RepaintBoundary(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PositionedDirectional(
                    start: 31.35 * scale,
                    top: 29.53 * scale + _headlineTopGap,
                    width: 249.7 * scale,
                    height: 113 * scale,
                    child: FadeTransition(
                      opacity: _headlineOpacity,
                      child: SlideTransition(
                        position: _headlineSlide,
                        textDirection: Directionality.of(context),
                        child: Center(
                          child: Transform.rotate(
                            angle: (isRTL ? 13 : -13) * math.pi / 180,
                            child: SizedBox(
                              width: 242.42 * scale,
                              child: Text(
                                '${LangKeys.neverMissOffersHeadlineFirstLineKey.tr()}\n${LangKeys.neverMissOffersHeadlineSecondLineKey.tr()}',
                                textAlign: TextAlign.start,
                                textScaler: TextScaler.noScaling,
                                style: AppTextStyles.style16Bold.copyWith(
                                  fontSize: 16 * scale,
                                  color: colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 16 * scale,
                    top: 52 * scale,
                    child: BigDiscountBadge(
                      size: 60 * scale,
                      animation: _introController,
                    ),
                  ),
                ],
              ),
            );
            final Widget logo = FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: isRTL
                    ? Assets.media.images.png.homeNeverMissOffersLogo.image(
                        fit: BoxFit.contain,
                      )
                    : Assets.media.images.png.englishOffersCannotMissLogo.image(
                        fit: BoxFit.contain,
                      ),
              ),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                OffersPatternBackground(scrollController: _scrollController),
                NotificationListener<ScrollUpdateNotification>(
                  onNotification: (ScrollUpdateNotification notification) {
                    if (notification.depth != 0) return false;
                    final bool isWaveFlattened =
                        notification.metrics.pixels >= logoPinOffset;
                    if (isWaveFlattened !=
                        _waveFlattenController.status.isForwardOrCompleted) {
                      isWaveFlattened
                          ? _waveFlattenController.forward()
                          : _waveFlattenController.reverse();
                    }
                    return false;
                  },
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(
                      overscroll: false,
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: isLoading
                          ? const NeverScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: headerHeight),
                          Consumer(
                            builder: (context, ref, _) {
                              final Object? error = ref.watch(
                                getHomeSectionsProvider.select(
                                  (AsyncValue<List<HomeSectionModel>> state) =>
                                      state.error,
                                ),
                              );
                              final List<ProductModel> products = ref.watch(
                                getHomeSectionsProvider.select(_offers),
                              );

                              // A failed refresh keeps the loaded offers, so
                              // the error only shows when there are none.
                              if (!isLoading && products.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: error == null
                                      ? NoResultsWidget(
                                          image: Assets
                                              .media
                                              .images
                                              .svg
                                              .noProductsIcon
                                              .svg(),
                                          emptyMessage: LangKeys.noOffersNowKey
                                              .tr(),
                                        )
                                      : ServerConnectionErrorWidget(
                                          message: error is String
                                              ? error
                                              : null,
                                          onRetry: ref
                                              .read(
                                                getHomeSectionsProvider
                                                    .notifier,
                                              )
                                              .reload,
                                        ),
                                );
                              }

                              return ProductDetailsListScope(
                                productSlugs: () =>
                                    products.map((product) => product.slug),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.64,
                                      ),
                                  itemCount: isLoading
                                      ? _shimmerItemsCount
                                      : products.length,
                                  itemBuilder: (context, index) => isLoading
                                      ? AppShimmer(
                                          baseColor: colors.purple800,
                                          highlightColor: Color.lerp(
                                            colors.purple800,
                                            colors.white,
                                            0.4,
                                          )!,
                                          child: const HomeNeverMissOffersItem(
                                            product: ProductModel(),
                                          ),
                                        )
                                      : HomeNeverMissOffersItem(
                                          product: products[index],
                                          onFavouriteChanged:
                                              (bool isFavourite) => ref
                                                  .read(
                                                    getHomeSectionsProvider
                                                        .notifier,
                                                  )
                                                  .updateProductFavourite(
                                                    products[index].id,
                                                    isFavourite,
                                                  ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: waveHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: isLoading
                        ? null
                        : (DragStartDetails details) =>
                              _waveDrag = _scrollController.position.drag(
                                details,
                                () => _waveDrag = null,
                              ),
                    onVerticalDragUpdate: (DragUpdateDetails details) =>
                        _waveDrag?.update(details),
                    onVerticalDragEnd: (DragEndDetails details) =>
                        _waveDrag?.end(details),
                    onVerticalDragCancel: () => _waveDrag?.cancel(),
                    child: RepaintBoundary(
                      child: ClipPath(
                        clipper: BottomWaveClipper(
                          textDirection: Directionality.of(context),
                          flatten: _waveFlatten,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: colors.purple800),
                            const OffersPatternBackground(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      final double scrollOffset = _scrollController.hasClients
                          ? _scrollController.offset
                          : 0;
                      return Stack(
                        children: [
                          Positioned(
                            top: -scrollOffset,
                            left: 0,
                            right: 0,
                            height: headerHeight,
                            child: header,
                          ),
                          PositionedDirectional(
                            end: _logoEnd * scale,
                            top:
                                statusBarHeight +
                                math.max(logoPinOffset - scrollOffset, 0),
                            width: _logoWidth * scale,
                            height: _logoHeight * scale,
                            child: logo,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // The icon sits where the design puts it; the padding only
                // grows the tap target to the 48 px minimum.
                PositionedDirectional(
                  start: _backIconStart - _backHitPadding,
                  top:
                      statusBarHeight +
                      (kToolbarHeight - _backIconSize) / 2 -
                      _backHitPadding,
                  child: Semantics(
                    button: true,
                    label: MaterialLocalizations.of(context).backButtonTooltip,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (context.canPop()) context.pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(_backHitPadding),
                        child: Transform.flip(
                          flipX: !isRTL,
                          child: Assets.media.images.svg.arrowBrokenIcon.svg(
                            colorFilter: ColorFilter.mode(
                              colors.white,
                              BlendMode.srcIn,
                            ),
                            width: _backIconSize,
                            height: _backIconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
