import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_body.dart';

/// Full-screen modal pager above the product's source list.
class ProductDetailsOverlay extends ConsumerStatefulWidget {
  const ProductDetailsOverlay({
    super.key,
    required this.productSlugs,
    this.initialIndex = 0,
  }) : assert(productSlugs.length > 0),
       assert(initialIndex >= 0 && initialIndex < productSlugs.length);

  final List<String> productSlugs;
  final int initialIndex;

  @override
  ConsumerState<ProductDetailsOverlay> createState() =>
      _ProductDetailsOverlayState();
}

class _ProductDetailsOverlayState extends ConsumerState<ProductDetailsOverlay> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
    viewportFraction: 0.9,
  );

  final Map<int, double> _scrollOffsets = {};
  final Map<int, double> _scrollProgress = {};
  final ValueNotifier<int> _scrollRevision = ValueNotifier(0);
  late final Listenable _geometry = Listenable.merge([
    _controller,
    _scrollRevision,
  ]);

  double get _page =>
      _controller.hasClients && _controller.position.hasContentDimensions
      ? _controller.page ?? widget.initialIndex.toDouble()
      : widget.initialIndex.toDouble();

  double get _expansion {
    final page = _page.clamp(0.0, widget.productSlugs.length - 1.0);
    final start = page.floor();
    final end = page.ceil();
    final fraction = page - start;
    return (_scrollProgress[start] ?? 0) * (1 - fraction) +
        (_scrollProgress[end] ?? 0) * fraction;
  }

  bool _onDetailsScroll(
    int index,
    double expansionExtent,
    ScrollNotification notification,
  ) {
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical ||
        (notification is! ScrollUpdateNotification &&
            notification is! OverscrollNotification)) {
      return false;
    }
    // Count overscroll too: a product with little content must still be able
    // to expand. Reverse gestures retrace the same distance to collapse it.
    final delta = notification is ScrollUpdateNotification
        ? notification.scrollDelta ?? 0
        : (notification as OverscrollNotification).overscroll;
    final maxOffset = notification.metrics.maxScrollExtent > expansionExtent
        ? notification.metrics.maxScrollExtent
        : expansionExtent;
    final offset = ((_scrollOffsets[index] ?? 0) + delta).clamp(0.0, maxOffset);
    _scrollOffsets[index] = offset;
    final progress = (offset / expansionExtent).clamp(0.0, 1.0);
    if (_scrollProgress[index] != progress) {
      _scrollProgress[index] = progress;
      _scrollRevision.value++;
    }
    return false;
  }

  @override
  void dispose() {
    _scrollRevision.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewPaddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // One pixel of scroll adds one pixel of height until the card fills
        // the screen. The body reserves this travel before scrolling content.
        final expansionExtent = insets.vertical + 32;
        return AnimatedBuilder(
          animation: _geometry,
          builder: (context, child) {
            final progress = _expansion;
            // Keep the same PageController and page states while widening its
            // viewport. At full expansion the 0.9 page fills the screen exactly.
            final width = constraints.maxWidth * (1 + (1 / 0.9 - 1) * progress);
            return ClipRect(
              child: Padding(
                padding: EdgeInsets.only(
                  top: (insets.top + 16) * (1 - progress),
                  bottom: (insets.bottom + 16) * (1 - progress),
                ),
                child: OverflowBox(
                  minWidth: width,
                  maxWidth: width,
                  child: child,
                ),
              ),
            );
          },
          child: PageView.builder(
            key: const ValueKey('product-details-pager'),
            controller: _controller,
            itemCount: widget.productSlugs.length,
            itemBuilder: (context, index) => AnimatedBuilder(
              animation: _geometry,
              builder: (context, child) {
                final progress = _expansion;
                final distance = (_page - index).abs().clamp(0.0, 1.0);
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4 * (1 - progress),
                    vertical: 24 * distance,
                  ),
                  child: Material(
                    key: ValueKey('product-details-surface-$index'),
                    color: context.colors.white,
                    borderRadius: BorderRadius.circular(24 * (1 - progress)),
                    clipBehavior: Clip.antiAlias,
                    // The body paints to the card edges. Its header and
                    // footer already keep their controls inside system insets.
                    child: child,
                  ),
                );
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) =>
                    _onDetailsScroll(index, expansionExtent, notification),
                child: ProductDetailsBody(
                  key: ValueKey(widget.productSlugs[index]),
                  productSlug: widget.productSlugs[index],
                  showCloseButton: true,
                  expansionScrollExtent: expansionExtent,
                  imageViewportSize: constraints.biggest,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
