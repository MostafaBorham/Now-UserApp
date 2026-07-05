import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 20,
      children: [
        Row(
          spacing: 10,
          children: [
            InkWell(
              onTap: () {
                _controller.previousPage();
              },
              child: Material(
                shape: CircleBorder(),
                elevation: 4,
                shadowColor: colors.onSurface.withValues(alpha: 0.3),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.onPrimary,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: colors.onSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              // Clips only horizontally so sliding items stay inside the slider
              // boundaries and never paint over the arrow buttons, while the
              // item's vertical drop-shadow is still allowed to show.
              child: ClipRect(
                clipper: _HorizontalClipper(),
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
            InkWell(
              onTap: () {
                _controller.nextPage();
              },
              child: Material(
                shape: CircleBorder(),
                elevation: 4,
                shadowColor: colors.onSurface.withValues(alpha: 0.3),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.onPrimary,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: colors.onSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        DotsIndicator(
          currentIndex: _currentIndex,
          itemCount: widget.itemCount,
          activeColor: widget.activeDotColor ?? colors.primary,
          inactiveColor: widget.dotColor ?? colors.onTertiary,
        ),
      ],
    );
  }
}

class _HorizontalClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTRB(
        0,
        -size.height,
        size.width,
        size.height * 2,
      );

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
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
            width: currentIndex == index
                ? activeWidth
                : inactiveWidth,
            height: height,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? activeColor
                  : inactiveColor,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}
