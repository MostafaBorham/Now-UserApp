import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';

/// A [PinnedHeaderSliver] for a scroll view that starts under
/// [AppWavedView]'s wave (a full-width body passed a `scrollController`).
/// [PinnedHeaderSliver] pins at the viewport top, where the wave covers it.
/// This one pins just below the wave's lowest point, and fills the strip
/// above it with [color] so content scrolling beneath does not show through
/// between the wave's crests. In the scroll it takes only its child's height.
class WavePinnedHeaderSliver extends SingleChildRenderObjectWidget {
  const WavePinnedHeaderSliver({
    super.key,
    required this.color,
    required Widget super.child,
  });

  /// Painted behind the child and the strip above it.
  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderWavePinnedHeader(color);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderWavePinnedHeader).color = color;
  }
}

// ponytail: assumes a downward vertical scroll view, as every wave body is.
class _RenderWavePinnedHeader extends RenderSliverSingleBoxAdapter {
  _RenderWavePinnedHeader(this._color);

  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  /// How far below its scroll position the child is held: 0 until it would
  /// rise into the wave.
  double _pin = 0;

  @override
  void performLayout() {
    final RenderBox child = this.child!;
    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double extent = child.size.height;
    final double inset = TopWaveClipper.depthFor(constraints.crossAxisExtent);
    // Where the sliver starts, from the viewport top: once scrolled past the
    // top it is laid out at 0; until then it starts where the viewport's
    // remaining room begins.
    final double top = constraints.scrollOffset > 0
        ? 0
        : constraints.viewportMainAxisExtent - constraints.remainingPaintExtent;
    _pin = math.max(0, inset - top);
    (child.parentData! as SliverPhysicalParentData).paintOffset = Offset(
      0,
      _pin,
    );
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: math.min(_pin + extent, constraints.remainingPaintExtent),
      layoutExtent: (extent - constraints.scrollOffset).clamp(
        0.0,
        constraints.remainingPaintExtent,
      ),
      maxPaintExtent: inset + extent,
      maxScrollObstructionExtent: inset + extent,
      cacheExtent: calculateCacheOffset(constraints, from: 0, to: extent),
      hasVisualOverflow: true,
    );
  }

  @override
  double childMainAxisPosition(RenderBox child) => _pin;

  // The filled strip takes the taps meant for what it hides.
  @override
  bool hitTestSelf({
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) => mainAxisPosition < _pin;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!geometry!.visible) return;
    context.canvas.drawRect(
      offset & Size(constraints.crossAxisExtent, geometry!.paintExtent),
      Paint()..color = _color,
    );
    super.paint(context, offset);
  }
}
