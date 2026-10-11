import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';

/// Holds a [CarouselSlider]'s autoplay for as long as a finger rests on it,
/// and resumes once the last one lifts — the special offers strip's rule.
///
/// The carousel's own `pauseAutoPlayOnTouch` resumed mid-hold whenever its
/// gesture recognizer lost the arena (BUG-012), so build the carousel with
/// `pauseAutoPlayOnTouch: false` and the controller handed to [builder].
class CarouselHold extends StatefulWidget {
  const CarouselHold({super.key, required this.builder});

  final Widget Function(CarouselSliderController controller) builder;

  @override
  State<CarouselHold> createState() => _CarouselHoldState();
}

class _CarouselHoldState extends State<CarouselHold> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _fingersDown = 0;

  void _down(PointerDownEvent _) {
    if (_fingersDown++ == 0) _controller.stopAutoPlay();
  }

  void _up(PointerEvent _) {
    if (--_fingersDown == 0) _controller.startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _up,
      child: widget.builder(_controller),
    );
  }
}
