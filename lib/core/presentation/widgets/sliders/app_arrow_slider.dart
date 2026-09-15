import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class AppArrowSlider extends StatefulWidget {
  const AppArrowSlider({
    super.key,
    this.activeDotColor,
    this.dotColor,
    required this.itemCount,
    required this.sliderItemBuilder,
    this.aboveImageBuilder,
    this.belowImageBuilder,
    this.sliderSpace = 8,
    this.itemHeight = 620,
  });

  final Color? activeDotColor;
  final Color? dotColor;



  final IndexedWidgetBuilder sliderItemBuilder;




  final IndexedWidgetBuilder? aboveImageBuilder;
  final IndexedWidgetBuilder? belowImageBuilder;

  final double sliderSpace;



  final double itemHeight;
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
    final TextDirection ambient = Directionality.of(context);
    return Column(
      children: [
        Directionality(
          textDirection: ambient == TextDirection.rtl
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: CarouselSlider.builder(
            carouselController: _controller,
            itemCount: widget.itemCount,
            itemBuilder: (BuildContext itemContext, index, _) => Directionality(
              textDirection: ambient,
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: widget.sliderSpace,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    if (widget.aboveImageBuilder != null) widget.aboveImageBuilder!(itemContext, index),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: AlignmentDirectional.center,
                      children: [


                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 44,
                          ),
                          child: widget.sliderItemBuilder(itemContext, index),
                        ),



                        if (widget.itemCount > 1) ...[
                          PositionedDirectional(
                            start: 0,
                            child: _SliderArrowButton(
                              icon: Icons.chevron_left,
                              onTap: () => _controller.previousPage(),
                            ),
                          ),
                          PositionedDirectional(
                            end: 0,
                            child: _SliderArrowButton(
                              icon: Icons.chevron_right,
                              onTap: () => _controller.nextPage(),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.belowImageBuilder != null) widget.belowImageBuilder!(itemContext, index),
                  ],
                ),
              ),
            ),
            options: CarouselOptions(
              enlargeCenterPage: false,
              viewportFraction: 1,
              clipBehavior: Clip.none,
              autoPlay: false,
              height: widget.itemHeight,


              scrollPhysics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index, _) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ),

        if (widget.itemCount > 1)
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

class _SliderArrowButton extends StatelessWidget {
  const _SliderArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: colors.black.withValues(alpha: 0.08)),
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
          onTap: onTap,
          child: Center(child: Icon(icon, size: 24, color: colors.black)),
        ),
      ),
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
