import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class AppArrowSlider extends StatefulWidget {
  const AppArrowSlider({
    super.key,
    this.activeDotColor,
    this.dotColor,
    required this.sliderItem,
    this.sliderSpace = 8,
    this.itemAspectRatio = 1,
    this.itemCount = 4,
  });

  final Color? activeDotColor;
  final Color? dotColor;
  final Widget sliderItem;
  final double sliderSpace;
  final double itemAspectRatio;
  final int itemCount;

  @override
  State<AppArrowSlider> createState() => _AppArrowSliderState();
}

class _AppArrowSliderState extends State<AppArrowSlider> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      spacing: 20,
      children: [
        // The arrows are overlaid on top of the carousel (painted after it)
        // and nothing clips, so the item's soft drop-shadow is free to spread
        // outward beneath the arrow buttons and — downward — beneath the dots
        // indicator that follows in the column.
        Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.center,
          children: [
            // Inset so the item image sits between the arrows while its
            // shadow still bleeds out under them.
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 44),
              // The carousel's underlying PageView flips its animation axis with
              // the ambient direction, so a slide ends up moving opposite to the
              // arrow that drove it. Feeding it the *inverse* direction makes the
              // slide travel toward the tapped arrow's side in both locales. The
              // dots below stay ambient, so the active dot starts on the reading
              // side (right in ar, left in en) and tracks the slide.
              child: Directionality(
                textDirection: Directionality.of(context) == TextDirection.rtl
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: CarouselSlider.builder(
                  carouselController: _controller,
                  itemCount: widget.itemCount,
                  itemBuilder: (_, index, _) {
                    return Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: widget.sliderSpace,
                      ),
                      child: widget.sliderItem,
                    );
                  },
                  options: CarouselOptions(
                    enlargeCenterPage: false,
                    viewportFraction: 1,
                    clipBehavior: Clip.none,
                    autoPlay: false,
                    aspectRatio: widget.itemAspectRatio,
                    // Only the arrow buttons drive the slider; manual
                    // swipe/drag scrolling is disabled.
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index, _) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.black.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.neutral500.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      _controller.previousPage();
                    },
                    child: Center(
                      child: Icon(
                        Icons.chevron_left,
                        size: 24,
                        color: colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.black.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.neutral500.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      _controller.nextPage();
                    },
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        DotsIndicator(
          currentIndex: _currentIndex,
          itemCount: widget.itemCount,
          activeColor: widget.activeDotColor ?? colors.primary500Main,
          inactiveColor: widget.dotColor ?? colors.onTertiary,
        ),
      ],
    );
  }
}

class DotsIndicator extends StatelessWidget {
  const DotsIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.grey,
    this.activeWidth = 20,
    this.inactiveWidth = 8,
    this.height = 8,
    this.spacing = 8,
    this.duration = const Duration(milliseconds: 250),
  });

  final int currentIndex;
  final int itemCount;

  final Color activeColor;
  final Color inactiveColor;

  final double activeWidth;
  final double inactiveWidth;
  final double height;
  final double spacing;

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeInOut,
            width: currentIndex == index ? activeWidth : inactiveWidth,
            height: height,
            decoration: BoxDecoration(
              color: currentIndex == index ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}
