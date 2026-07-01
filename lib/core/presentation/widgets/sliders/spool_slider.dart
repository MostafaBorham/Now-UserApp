import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// One category shown in the spool slider.
class SpoolItem {
  const SpoolItem({
    required this.label,
    this.icon,
    this.image,
    this.color = const Color(0xFFFFE6A1),
  });

  final String label;

  /// Placeholder icon, used when [image] is null so the widget runs with no
  /// assets. Swap in [image] for real category thumbnails.
  final IconData? icon;

  /// Real thumbnail, e.g. NetworkImage(...) or AssetImage(...).
  final ImageProvider? image;

  /// Background tint behind the placeholder icon.
  final Color color;
}

// ---------------------------------------------------------------------------
// THE SPOOL SLIDER
// ---------------------------------------------------------------------------

/// A curved carousel where items ride along an arc. The centred item is
/// enlarged and reported through [onSelected]. Drag horizontally to rotate;
/// it snaps to the nearest item and supports fling.
///
/// All of the geometry is driven by [angularSpacing] (gap between items) and
/// [curvature] (how flat the arc is), so it adapts to any width.
class SpoolSlider extends StatefulWidget {
  const SpoolSlider({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onSelected,
    this.height = 230,
    this.itemDiameter = 72,
    this.minScale = 0.55,
    this.angularSpacing = 0.30, // radians between neighbours (~17°)
    this.curvature = 1.25, // arc radius = width * curvature (bigger = flatter)
    this.arcColor = const Color(0xFFFFC107),
    this.selectedLabelColor = const Color(0xFF2E9E3F),
    this.labelColor = const Color(0xFF7A7A7A),
    this.reverse = false, // flip drag direction (handy for RTL feel)
  });

  final List<SpoolItem> items;
  final int initialIndex;
  final ValueChanged<int>? onSelected;
  final double height;
  final double itemDiameter;
  final double minScale;
  final double angularSpacing;
  final double curvature;
  final Color arcColor;
  final Color selectedLabelColor;
  final Color labelColor;
  final bool reverse;

  @override
  State<SpoolSlider> createState() => _SpoolSliderState();
}

class _SpoolSliderState extends State<SpoolSlider>
    with SingleTickerProviderStateMixin {
  /// Fractional index currently sitting at the centre slot.
  late double _page;

  late final AnimationController _controller;
  Animation<double>? _anim;
  int _reported = -1;

  /// Pixels of horizontal drag that equal moving by one item.
  static const double _dragPerIndex = 105;

  /// Items past this angular offset are off the visible arc.
  static const double _maxPhi = 1.0;

  @override
  void initState() {
    super.initState();
    _page = widget.initialIndex.toDouble();
    _reported = widget.initialIndex;
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 380),
        )..addListener(() {
          if (_anim != null) setState(() => _page = _anim!.value);
          _maybeReport();
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _maxIndex => widget.items.length - 1;

  void _maybeReport() {
    final i = _page.round().clamp(0, _maxIndex);
    if (i != _reported) {
      _reported = i;
      widget.onSelected?.call(i);
    }
  }

  void _onDragStart(DragStartDetails _) => _controller.stop();

  void _onDragUpdate(DragUpdateDetails d) {
    final dir = widget.reverse ? -1 : 1;
    setState(() {
      _page -= dir * d.delta.dx / _dragPerIndex;
      _page = _page.clamp(0.0, _maxIndex.toDouble());
    });
    _maybeReport();
  }

  void _onDragEnd(DragEndDetails d) {
    final dir = widget.reverse ? -1 : 1;
    // Convert the fling velocity into an index velocity and project a little.
    final indexVelocity = -dir * d.velocity.pixelsPerSecond.dx / _dragPerIndex;
    final projected = _page + indexVelocity * 0.12;
    final target = projected.round().clamp(0, _maxIndex).toDouble();
    _animateTo(target);
  }

  void _animateTo(double target) {
    _anim = Tween<double>(
      begin: _page,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller
      ..value = 0
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cx = w / 2;
            final radius = w * widget.curvature;
            // y of the centred item's circle-centre.
            final topY = widget.itemDiameter * 0.95;
            final cy = topY + radius; // circle centre sits far below the view

            // Work out which items are on-screen and where.
            final placed = <_Placed>[];
            for (var i = 0; i < widget.items.length; i++) {
              final phi = (i - _page) * widget.angularSpacing;
              if (phi.abs() > _maxPhi) continue;
              final x = cx + radius * math.sin(phi);
              final y = cy - radius * math.cos(phi);
              placed.add(_Placed(i, phi, x, y));
            }
            // Paint outermost first so the centre item ends up on top.
            placed.sort((a, b) => b.phi.abs().compareTo(a.phi.abs()));

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ArcPainter(
                      color: widget.arcColor,
                      cx: cx,
                      cy: cy,
                      // Crest sits just under the item centres so they "rest"
                      // on the hill.
                      radius: radius - widget.itemDiameter * 0.18,
                    ),
                  ),
                ),
                for (final p in placed) _buildItem(p),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(_Placed p) {
    final item = widget.items[p.index];
    final t = (p.phi.abs() / _maxPhi).clamp(0.0, 1.0);
    final scale = lerpDouble(
      1.0,
      widget.minScale,
      Curves.easeOut.transform(t),
    )!;
    final opacity = lerpDouble(1.0, 0.35, t)!;
    final isCentre = p.index == _page.round();

    const boxWidth = 110.0;
    final d = widget.itemDiameter;

    return Positioned(
      left: p.x - boxWidth / 2,
      top: p.y - d / 2,
      width: boxWidth,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Thumb(
                item: item,
                diameter: d,
                highlighted: isCentre,
                ringColor: widget.arcColor,
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCentre ? 16 : 13,
                  fontWeight: isCentre ? FontWeight.w800 : FontWeight.w500,
                  color: isCentre
                      ? widget.selectedLabelColor
                      : widget.labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resolved on-screen placement for one item.
class _Placed {
  _Placed(this.index, this.phi, this.x, this.y);
  final int index;
  final double phi; // angular offset from centre
  final double x;
  final double y;
}

// ---------------------------------------------------------------------------
// VISUAL PIECES
// ---------------------------------------------------------------------------

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.item,
    required this.diameter,
    required this.highlighted,
    required this.ringColor,
  });

  final SpoolItem item;
  final double diameter;
  final bool highlighted;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: highlighted ? ringColor : Colors.white,
          width: highlighted ? 4 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(highlighted ? 0.22 : 0.10),
            blurRadius: highlighted ? 16 : 7,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: item.image != null
          ? Image(image: item.image!, fit: BoxFit.cover)
          : Container(
              color: item.color,
              alignment: Alignment.center,
              child: Icon(
                item.icon ?? Icons.category_rounded,
                size: diameter * 0.45,
                color: Colors.black87,
              ),
            ),
    );
  }
}

/// Fills everything below a circular crest, producing the yellow hill.
class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.color,
    required this.cx,
    required this.cy,
    required this.radius,
  });

  final Color color;
  final double cx, cy, radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.lerp(color, Colors.white, 0.18)!, color],
      ).createShader(rect);

    final path = Path()..moveTo(0, size.height);
    // Trace the circle's top edge across the width.
    for (double x = 0; x <= size.width; x += 3) {
      final dx = x - cx;
      final inside = radius * radius - dx * dx;
      final y = inside > 0 ? cy - math.sqrt(inside) : size.height;
      path.lineTo(x, y.clamp(0.0, size.height));
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.cx != cx ||
      old.cy != cy ||
      old.radius != radius ||
      old.color != color;
}

// ---------------------------------------------------------------------------
// DEMO  (delete everything below when you drop SpoolSlider into your app)
// ---------------------------------------------------------------------------

class SpoolDemoPage extends StatefulWidget {
  const SpoolDemoPage({super.key});

  @override
  State<SpoolDemoPage> createState() => _SpoolDemoPageState();
}

class _SpoolDemoPageState extends State<SpoolDemoPage> {
  // عروض is placed in the middle so it starts centred.
  static const _items = <SpoolItem>[
    SpoolItem(label: 'المنزل', icon: Icons.chair_rounded),
    SpoolItem(label: 'الإلكترونيات', icon: Icons.devices_rounded),
    SpoolItem(label: 'الخضروات', icon: Icons.eco_rounded),
    SpoolItem(label: 'الموضة', icon: Icons.checkroom_rounded),
    SpoolItem(label: 'عروض', icon: Icons.local_offer_rounded), // centre
    SpoolItem(label: 'الجمال', icon: Icons.brush_rounded),
    SpoolItem(label: 'الرياضة', icon: Icons.sports_soccer_rounded),
    SpoolItem(label: 'الأطفال', icon: Icons.toys_rounded),
  ];

  int _selected = 4;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const _ClearanceBanner(),
                    const SizedBox(height: 28),
                    SpoolSlider(
                      items: _items,
                      initialIndex: _selected,
                      onSelected: (i) => setState(() => _selected = i),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'المحدد: ${_items[_selected].label}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pink "80% clearance" pill at the top of the reference image.
class _ClearanceBanner extends StatelessWidget {
  const _ClearanceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '%80',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'تخفيضات التصفية',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
