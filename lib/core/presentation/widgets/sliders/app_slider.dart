import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// An auto-playing carousel with a dots indicator.
///
/// The page index is plain local state. It used to live in a `StateProvider`
/// built inside the widget's own field initializer, so every re-construction of
/// the widget minted a *different* provider and the dots snapped back to the
/// first page while the carousel stayed where it was — visible on store
/// details, where the slider sits in `NestedScrollView.headerSliverBuilder` and
/// is therefore rebuilt as the page scrolls.
class AppSlider extends StatefulWidget {
  const AppSlider({
    super.key,
    this.activeDotColor,
    this.dotColor,
    required this.sliderItems,
    this.sliderSpace = 8,
    this.itemAspectRatio = 1,
    this.showIndicator = true,
  });

  final Color? activeDotColor;
  final Color? dotColor;
  final List<Widget> sliderItems;
  final double? sliderSpace;
  final double? itemAspectRatio;

  /// Whether to show the page-dots indicator under the carousel (only ever
  /// shown for multi-item sliders). Off for the home top banner.
  final bool showIndicator;

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant AppSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A shorter list can leave the index past its end.
    if (_index >= widget.sliderItems.length) _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isSingleItem = widget.sliderItems.length == 1;
    if (widget.sliderItems.isEmpty) return const SizedBox.shrink();

    return Column(
      spacing: 20,
      children: [
        CarouselSlider.builder(
          itemCount: widget.sliderItems.length,
          itemBuilder: (_, index, _) {
            return Padding(
              padding: EdgeInsets.all(widget.sliderSpace!),
              child: widget.sliderItems.elementAt(index),
            );
          },
          options: CarouselOptions(
            enlargeCenterPage: false,
            autoPlay: !isSingleItem,
            // App-wide motion rule: anything that moves on its own travels
            // with the locale's reading sweep — right-to-left in Arabic,
            // left-to-right in English (the same rule the delivery-man
            // animation follows via `ReverseWidget`). A `PageView` lays its
            // pages out in index order, which drifts the opposite way in both
            // locales, so `reverse` flips it: the next item enters from the
            // leading edge and the current one leaves by the trailing edge.
            reverse: true,
            scrollPhysics: isSingleItem
                ? const NeverScrollableScrollPhysics()
                : null,
            aspectRatio: widget.itemAspectRatio!,
            viewportFraction: isSingleItem ? 1 : 0.9,
            onPageChanged: isSingleItem
                ? null
                : (index, _) => setState(() => _index = index),
          ),
        ),
        if (!isSingleItem && widget.showIndicator)
          AnimatedSmoothIndicator(
            activeIndex: _index,
            count: widget.sliderItems.length,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: widget.activeDotColor ?? colors.primary500Main,
              dotColor: widget.dotColor ?? colors.onTertiary,
            ),
          ),
      ],
    );
  }
}
