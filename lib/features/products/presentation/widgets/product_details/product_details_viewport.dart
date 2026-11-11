import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

/// Fits the page to its animated bounds without reflowing all product text.
/// Only the scroll viewport's height changes; content keeps its final width.
class ProductDetailsViewport extends StatefulWidget {
  const ProductDetailsViewport({
    super.key,
    required this.contentWidth,
    required this.child,
  });

  final double contentWidth;
  final Widget child;

  static ValueListenable<double> scaleOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ViewportScale>()?.scale ??
      const AlwaysStoppedAnimation(1);

  @override
  State<ProductDetailsViewport> createState() => _ProductDetailsViewportState();
}

class _ProductDetailsViewportState extends State<ProductDetailsViewport> {
  final ValueNotifier<double> _scale = ValueNotifier(1);

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = constraints.maxWidth / widget.contentWidth;
      _scale.value = scale;
      return FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: widget.contentWidth,
          height: constraints.maxHeight / scale,
          child: _ViewportScale(scale: _scale, child: widget.child),
        ),
      );
    },
  );
}

class _ViewportScale extends InheritedWidget {
  const _ViewportScale({required this.scale, required super.child});
  final ValueListenable<double> scale;

  @override
  bool updateShouldNotify(_ViewportScale oldWidget) => oldWidget.scale != scale;
}

/// Keep drag distances/velocities in screen pixels as the page scales.
class ProductDetailsScrollPhysics extends ScrollPhysics {
  const ProductDetailsScrollPhysics({
    required this.viewportScale,
    super.parent,
  });
  final ValueListenable<double> viewportScale;

  @override
  ProductDetailsScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      ProductDetailsScrollPhysics(
        viewportScale: viewportScale,
        parent: buildParent(ancestor),
      );

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) =>
      super.applyPhysicsToUserOffset(position, offset * viewportScale.value);

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) =>
      super.createBallisticSimulation(position, velocity * viewportScale.value);
}
