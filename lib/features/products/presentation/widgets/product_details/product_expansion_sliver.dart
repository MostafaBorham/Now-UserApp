import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reserves scroll travel for expanding the modal without moving its content.
class ProductExpansionSliver extends LeafRenderObjectWidget {
  const ProductExpansionSliver({super.key, required this.extent});

  final double extent;

  @override
  RenderSliver createRenderObject(BuildContext context) =>
      RenderProductExpansionSliver(extent);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderProductExpansionSliver renderObject,
  ) => renderObject.extent = extent;
}

class RenderProductExpansionSliver extends RenderSliver {
  RenderProductExpansionSliver(this._extent);

  double _extent;

  set extent(double value) {
    if (_extent == value) return;
    _extent = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    geometry = SliverGeometry(scrollExtent: _extent);
  }
}
