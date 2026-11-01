import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Pins its [child] to the top of the enclosing scroll view once the child's
/// leading edge scrolls up to [pinTop] pixels from the viewport top, then holds
/// it there while the rest of the page keeps scrolling underneath.
///
/// It drives the *real* child (a single instance — no duplicated overlay copy)
/// with a scroll-following [Transform.translate], so any state the child owns is
/// preserved. While pinned an opaque [background] is painted behind it, bled out
/// by [horizontalBleed] on each side so it can span the full screen width even
/// when the child sits inside a horizontally-padded parent.
class StickyOnScroll extends StatefulWidget {
  const StickyOnScroll({
    super.key,
    required this.pinTop,
    required this.background,
    required this.child,
    this.horizontalBleed = 0,
  });

  /// Distance from the viewport top at which the child locks in place (e.g. the
  /// height of an already-pinned bar above it). Updates re-resolve the anchor.
  final ValueListenable<double> pinTop;

  /// Painted behind the child while pinned, so content scrolling beneath does
  /// not show through the child's transparent regions.
  final Color background;

  /// How far the background extends past the child on each side, to reach the
  /// screen edges through a padded ancestor.
  final double horizontalBleed;

  final Widget child;

  @override
  State<StickyOnScroll> createState() => _StickyOnScrollState();
}

class _StickyOnScrollState extends State<StickyOnScroll> {
  final ValueNotifier<double> _translation = ValueNotifier<double>(0);

  ScrollPosition? _position;
  bool _recheckScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.pinTop.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollPosition? position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_onScroll);
      _position = position;
      _position?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.pinTop.removeListener(_onScroll);
    _position?.removeListener(_onScroll);
    _translation.dispose();
    super.dispose();
  }

  /// Scroll offset at which the child's top reaches [pinTop]. Measured on
  /// every scroll rather than cached once: the content above (the live-orders
  /// strip, special offers, a section appearing) changes height after the
  /// first layout, and a cached value then parked the bar too high or too low
  /// (BUG-008). Measured on this widget's own box, which sits outside the
  /// translate, so the reading isn't skewed by it.
  double? _threshold() {
    final RenderObject? box = context.findRenderObject();
    if (box == null || !box.attached) return null;
    final double reveal = RenderAbstractViewport.of(
      box,
    ).getOffsetToReveal(box, 0.0).offset;
    return (reveal - widget.pinTop.value).clamp(0.0, double.infinity);
  }

  void _onScroll() {
    final ScrollPosition? position = _position;
    if (position == null) return;
    final double? threshold = _threshold();
    if (threshold == null) return;
    // Beyond the threshold, translate down by exactly the extra scroll so the
    // child stays parked at [pinTop]; before it, ride along with the page.
    final double dy = (position.pixels - threshold).clamp(0.0, double.infinity);
    if (dy != _translation.value) _translation.value = dy;
    if (dy > 0) _recheckAfterFrame();
  }

  /// While pinned, measured again after every frame. Layout can move the page
  /// with no scroll event: a tab with fewer stores shortens the list, and at
  /// the end of the page that pulls the scroll offset back without telling
  /// listeners, which left the bar at the old translation, floating mid-screen
  /// over the stores. Never asks for a frame itself.
  void _recheckAfterFrame() {
    if (_recheckScheduled) return;
    _recheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recheckScheduled = false;
      if (mounted) _onScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _translation,
      child: widget.child,
      builder: (context, dy, child) {
        return Transform.translate(
          offset: Offset(0, dy),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              if (dy > 0)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: -widget.horizontalBleed,
                  right: -widget.horizontalBleed,
                  child: ColoredBox(color: widget.background),
                ),
              child!,
            ],
          ),
        );
      },
    );
  }
}
