import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';






typedef _CarouselItem = ({String label, String? imageUrl, VoidCallback? onTap});














class HomeAppCategoriesView extends ConsumerStatefulWidget {
  const HomeAppCategoriesView({super.key});

  @override
  ConsumerState<HomeAppCategoriesView> createState() =>
      _HomeAppCategoriesViewState();
}

class _HomeAppCategoriesViewState extends ConsumerState<HomeAppCategoriesView> {


  static const int _maxItems = 5;

  @override
  void initState() {
    super.initState();





    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(getAppCategoriesProvider).hasValue) return;
      ref.read(getAppCategoriesProvider.notifier).loadFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginationModel<CategoryModel>> state = ref.watch(
      getAppCategoriesProvider,
    );

    final List<_CarouselItem> items = state.maybeWhen(
      data: (PaginationModel<CategoryModel> page) {
        final List<CategoryModel> categories = page.data
            .take(_maxItems)
            .toList();
        if (categories.isEmpty) return _placeholderItems;
        return categories
            .map(
              (CategoryModel category) => (
                label: context.getLocalizedApiText(category.name),

                imageUrl: category.image,
                onTap: () => context.pushNamed(
                  AppRoutes.categoryDetailsScreen,
                  extra: category,
                ),
              ),
            )
            .toList();
      },
      orElse: () => _placeholderItems,
    );

    return _CategoriesCarousel(items: items);
  }




  static final List<_CarouselItem> _placeholderItems =
      List<_CarouselItem>.generate(
        _maxItems,
        (_) => (label: '', imageUrl: null, onTap: null),
      );
}






class _CategoriesCarousel extends StatefulWidget {
  const _CategoriesCarousel({required this.items});

  final List<_CarouselItem> items;

  @override
  State<_CategoriesCarousel> createState() => _CategoriesCarouselState();
}

class _CategoriesCarouselState extends State<_CategoriesCarousel> {

  static const int _initialPage = 10000;
  static const Duration _slideInterval = Duration(seconds: 3);
  static const Duration _slideDuration = Duration(milliseconds: 900);

  late final PageController _controller;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.26,
    );


    _autoSlideTimer = Timer.periodic(_slideInterval, (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(duration: _slideDuration, curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<_CarouselItem> items = widget.items;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        return SizedBox(
          height: width * 0.42,
          child: PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),



            reverse: true,
            itemBuilder: (context, index) {
              final _CarouselItem item = items[index % items.length];
              return _CategoryCarouselItem(
                controller: _controller,
                index: index,
                width: width,
                label: item.label,
                imageUrl: item.imageUrl,
                onTap: item.onTap,
                colors: colors,
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryCarouselItem extends StatelessWidget {
  const _CategoryCarouselItem({
    required this.controller,
    required this.index,
    required this.width,
    required this.label,
    required this.imageUrl,
    required this.onTap,
    required this.colors,
  });

  final PageController controller;
  final int index;
  final double width;
  final String label;
  final String? imageUrl;
  final VoidCallback? onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final double diameter = width * 0.26;

    final double minImageSize = diameter * 0.5;
    final double maxImageSize = diameter * 1.2;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final bool ready =
              controller.hasClients && controller.position.haveDimensions;
          final double page = ready
              ? controller.page!
              : controller.initialPage.toDouble();
          final double distance = (page - index).abs().clamp(0.0, 1.0);
          final double proximity = 1.0 - distance;
          final double scale = 1.0 - distance * 0.32;
          final double rawImageSize =
              minImageSize + (maxImageSize - minImageSize) * proximity;


          final bool isCentered = rawImageSize > diameter;
          final double padding = diameter * 0.14;
          final double imageSize = isCentered
              ? rawImageSize
              : rawImageSize.clamp(minImageSize, diameter - padding * 2);
          return Transform.scale(
            scale: scale,


            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: diameter,
                    height: diameter,
                    padding: EdgeInsets.all(diameter * 0.1),
                    clipBehavior: imageSize > diameter
                        ? Clip.none
                        : Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.white, colors.onSecondaryFixed],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.5, 1],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      alignment: Alignment.center,


                      child: (imageUrl == null || imageUrl!.isEmpty)
                          ? const SizedBox.shrink()
                          : CachedNetworkImage(
                              imageUrl: imageUrl!,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                              memCacheWidth:
                                  (imageSize *
                                          MediaQuery.devicePixelRatioOf(context))
                                      .round(),
                              memCacheHeight:
                                  (imageSize *
                                          MediaQuery.devicePixelRatioOf(context))
                                      .round(),
                              placeholder: (context, url) =>
                                  const SizedBox.shrink(),
                              errorWidget: (context, url, error) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  ),


                  if (label.isNotEmpty) ...[
                    SizedBox(height: width * 0.02),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: width * 0.042,
                        fontWeight: isCentered
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
