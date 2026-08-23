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
  final GlobalKey _childKey = GlobalKey();
  final ValueNotifier<double> _translation = ValueNotifier<double>(0);

  ScrollPosition? _position;

  /// Scroll offset at which the child's top reaches [pinTop]. Resolved lazily
  /// (while still unpinned, so the measurement isn't skewed by our own
  /// translate) and cached; invalidated when [pinTop] changes.
  double? _threshold;

  @override
  void initState() {
    super.initState();
    widget.pinTop.addListener(_onPinTopChanged);
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
    widget.pinTop.removeListener(_onPinTopChanged);
    _position?.removeListener(_onScroll);
    _translation.dispose();
    super.dispose();
  }

  void _onPinTopChanged() {
    _threshold = null;
    _onScroll();
  }

  double? _resolveThreshold() {
    if (_threshold != null) return _threshold;
    final RenderObject? box = _childKey.currentContext?.findRenderObject();
    if (box == null || !box.attached) return null;
    final double reveal = RenderAbstractViewport.of(
      box,
    ).getOffsetToReveal(box, 0.0).offset;
    return _threshold = (reveal - widget.pinTop.value).clamp(
      0.0,
      double.infinity,
    );
  }

  void _onScroll() {
    final ScrollPosition? position = _position;
    if (position == null) return;
    final double? threshold = _resolveThreshold();
    if (threshold == null) return;
    // Beyond the threshold, translate down by exactly the extra scroll so the
    // child stays parked at [pinTop]; before it, ride along with the page.
    final double dy = (position.pixels - threshold).clamp(0.0, double.infinity);
    if (dy != _translation.value) _translation.value = dy;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _translation,
      child: KeyedSubtree(key: _childKey, child: widget.child),
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
