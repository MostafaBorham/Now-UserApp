import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StickyOnScroll extends StatefulWidget {
  const StickyOnScroll({
    super.key,
    required this.pinTop,
    required this.background,
    required this.child,
    this.horizontalBleed = 0,
  });

  final ValueListenable<double> pinTop;

  final Color background;

  final double horizontalBleed;

  final Widget child;

  @override
  State<StickyOnScroll> createState() => _StickyOnScrollState();
}

class _StickyOnScrollState extends State<StickyOnScroll> {
  final GlobalKey _childKey = GlobalKey();
  final ValueNotifier<double> _translation = ValueNotifier<double>(0);

  ScrollPosition? _position;

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
