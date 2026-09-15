import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';


























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


  final int itemCount;


  final Widget Function(BuildContext context, int index) itemBuilder;


  final double itemWidth;


  final double separatorWidth;


  final double pixelsPerSecond;

  final EdgeInsetsGeometry padding;

  @override
  State<InfiniteAutoScrollList> createState() => _InfiniteAutoScrollListState();
}

class _InfiniteAutoScrollListState extends State<InfiniteAutoScrollList>
    with SingleTickerProviderStateMixin {



  static const int _repeat = 1000;

  late final ScrollController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;



  bool _userScrolling = false;



  bool _programmatic = false;

  double get _slotExtent => widget.itemWidth + widget.separatorWidth;

  double get _cycleExtent => widget.itemCount * _slotExtent;

  double get _centerOffset => _cycleExtent * (_repeat ~/ 2);

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _ticker = createTicker(_onTick);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _jumpTo(_centerOffset);
      _ticker.start();
    });
  }

  void _jumpTo(double value) {
    _programmatic = true;
    _controller.jumpTo(value);
    _programmatic = false;
  }

  void _onTick(Duration elapsed) {
    if (!_controller.hasClients || _cycleExtent <= 0) return;

    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000;
    _lastElapsed = elapsed;


    if (_userScrolling || dt <= 0) return;

    double target = _controller.offset + widget.pixelsPerSecond * dt;


    if (target >= _centerOffset + _cycleExtent) target -= _cycleExtent;
    _jumpTo(target);
  }

  bool _onNotification(ScrollNotification notification) {

    if (_programmatic) return false;

    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {

      _userScrolling = true;
    } else if (notification is ScrollEndNotification) {


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

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,




          reverse: true,
          physics: const BouncingScrollPhysics(),
          padding: widget.padding,
          itemExtent: _slotExtent,
          itemCount: widget.itemCount * _repeat,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsetsDirectional.only(end: widget.separatorWidth),
            child: SizedBox(
              width: widget.itemWidth,
              child: widget.itemBuilder(context, index % widget.itemCount),
            ),
          ),
        ),
      ),
    );
  }
}
