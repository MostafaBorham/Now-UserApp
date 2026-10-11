import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A horizontal list that scrolls forever at a constant, linear velocity while
/// still letting the user take over whenever they want.
///
/// The content is treated like a circular linked list: as the offset reaches
/// the end of one full cycle of items it is wrapped back by exactly one cycle,
/// so the first item appears seamlessly after the last one — no reverse motion,
/// no visible jump.
///
/// User interaction:
/// - The user can grab and scroll the list freely in either direction. While a
///   drag or its fling is in flight the automatic motion pauses; it resumes the
///   moment the list settles back to idle.
/// - To make manual scrolling feel endless in both directions, the offset is
///   parked in the middle of a large virtual list, leaving a full cycle of room
///   on each side; once the gesture ends the offset is re-centred by whole
///   cycles, which is invisible because the content repeats every cycle.
///
/// A row that fits the strip doesn't loop: it shows still, with no ticker —
/// looping it put the same few products side by side (BUG-011).
///
/// Performance notes:
/// - Motion is driven by a single [Ticker] that calls [ScrollController.jumpTo]
///   each frame. `jumpTo` only repositions the viewport; it never rebuilds the
///   item widgets, so there is no per-frame `setState`.
/// - Items are built lazily by [ListView.builder]; only the on-screen ones exist
///   in the tree regardless of how "infinite" the list is.
/// - Every slot has a fixed [itemExtent], which lets the list skip per-child
///   layout measurement and keeps the cycle geometry exact for a seamless wrap.
class InfiniteAutoScrollList extends StatefulWidget {
  const InfiniteAutoScrollList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemWidth,
    this.separatorWidth = 0,
    this.pixelsPerSecond = 18,
    this.padding = EdgeInsets.zero,
  });

  /// Number of distinct items that make up a single cycle.
  final int itemCount;

  /// Builds one item given its index in `[0, itemCount)`.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Width of a single item (without the trailing separator space).
  final double itemWidth;

  /// Empty space rendered after every item.
  final double separatorWidth;

  /// Constant scroll speed in logical pixels per second.
  final double pixelsPerSecond;

  final EdgeInsetsGeometry padding;

  @override
  State<InfiniteAutoScrollList> createState() => _InfiniteAutoScrollListState();
}

class _InfiniteAutoScrollListState extends State<InfiniteAutoScrollList>
    with SingleTickerProviderStateMixin {
  // How many times the cycle is repeated to form the virtual scroll extent.
  // Building is lazy, so a large value is essentially free and gives the user
  // effectively unlimited room to drag either way.
  static const int _repeat = 1000;

  // Seconds between two ticks beyond which the list does not move for it.
  static const double _maxTickGap = 0.1;

  late final ScrollController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // True while a real user gesture (drag or its fling) owns the scroll, so the
  // ticker stands down and lets the user drive.
  bool _userScrolling = false;

  // True only while we are driving the scroll ourselves; used to ignore the
  // start/update/end notifications that `jumpTo` emits on every frame.
  bool _programmatic = false;

  // Fingers resting on the list. A press that doesn't drag sends no scroll
  // notification, so the strip used to slide on under it (BUG-021, QA V2).
  int _fingersDown = 0;

  // Whether the items overflow the strip; only then does it loop and move.
  bool _loops = false;

  // Whether the looping list has been parked in its centre band yet.
  bool _centered = false;

  double get _slotExtent => widget.itemWidth + widget.separatorWidth;

  double get _cycleExtent => widget.itemCount * _slotExtent;

  double get _centerOffset => _cycleExtent * (_repeat ~/ 2);

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _ticker = createTicker(_onTick);
  }

  /// Runs the ticker exactly while the strip loops. After layout, so a list
  /// that just started looping has its controller attached by the first tick.
  void _syncTicker() {
    if (!mounted) return;
    if (_loops && !_ticker.isActive) {
      _centered = false;
      _lastElapsed = Duration.zero;
      _ticker.start();
    } else if (!_loops && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _jumpTo(double value) {
    _programmatic = true;
    _controller.jumpTo(value);
    _programmatic = false;
  }

  void _onTick(Duration elapsed) {
    if (!_controller.hasClients || _cycleExtent <= 0) return;
    // Park the offset in the middle first, leaving a cycle of room either way.
    if (!_centered) {
      _centered = true;
      _jumpTo(_centerOffset);
    }
    // Skip the first tick so the initial delta is measured from a real frame.
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000;
    _lastElapsed = elapsed;
    // While the user is in control, hold still and keep the clock in sync so we
    // resume with a small delta instead of a jump. A gap longer than any frame
    // means the ticker was muted (scrolled off screen, another tab, a pushed
    // route) — resync the same way, or the strip leaps ahead on its return.
    if (_userScrolling || _fingersDown > 0 || dt <= 0 || dt > _maxTickGap) {
      return;
    }

    double target = _controller.offset + widget.pixelsPerSecond * dt;
    // Wrap back by whole cycles; the content one cycle earlier is identical, so
    // this is invisible.
    if (target >= _centerOffset + _cycleExtent) target -= _cycleExtent;
    _jumpTo(target);
  }

  bool _onNotification(ScrollNotification notification) {
    // Our own jumpTo emits notifications every frame — ignore those.
    if (_programmatic) return false;

    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {
      // A real gesture (drag or its ballistic fling) is moving the list.
      _userScrolling = true;
    } else if (notification is ScrollEndNotification) {
      // The list has come to rest: snap back into the centre band by whole
      // cycles (invisible) and hand control back to the ticker.
      _userScrolling = false;
      _recenter();
    }
    return false;
  }

  void _recenter() {
    if (!_controller.hasClients || _cycleExtent <= 0) return;
    final double offset = _controller.offset;
    final double normalized =
        _centerOffset + (offset - _centerOffset) % _cycleExtent;
    if ((normalized - offset).abs() > 0.5) _jumpTo(normalized);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _item(BuildContext context, int index) => Padding(
    padding: EdgeInsetsDirectional.only(end: widget.separatorWidth),
    child: SizedBox(
      width: widget.itemWidth,
      child: widget.itemBuilder(context, index % widget.itemCount),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available =
            constraints.maxWidth -
            widget.padding.resolve(Directionality.of(context)).horizontal;
        final bool loops =
            _cycleExtent - widget.separatorWidth > available + 0.5;
        if (loops != _loops) {
          _loops = loops;
          WidgetsBinding.instance.addPostFrameCallback((_) => _syncTicker());
        }
        if (!loops) {
          // Still, from the reading start.
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: widget.padding,
            itemExtent: _slotExtent,
            itemCount: widget.itemCount,
            itemBuilder: _item,
          );
        }
        return _looping();
      },
    );
  }

  Widget _looping() {
    return RepaintBoundary(
      child: Listener(
        onPointerDown: (_) => _fingersDown++,
        onPointerUp: (_) => _fingersDown--,
        onPointerCancel: (_) => _fingersDown--,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onNotification,
          child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            // App-wide motion rule (see `AppSlider`): self-moving content travels
            // with the locale's reading sweep. Index order drifts the opposite
            // way in both locales, so `reverse` flips it — items enter from the
            // leading edge and leave by the trailing one.
            reverse: true,
            physics: const BouncingScrollPhysics(),
            padding: widget.padding,
            itemExtent: _slotExtent,
            itemCount: widget.itemCount * _repeat,
            itemBuilder: _item,
          ),
        ),
      ),
    );
  }
}
