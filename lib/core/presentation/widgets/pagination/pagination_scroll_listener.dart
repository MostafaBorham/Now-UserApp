import 'package:flutter/material.dart';

class PaginationScrollListener extends StatelessWidget {
  const PaginationScrollListener({
    super.key,
    required this.child,
    required this.onLoadNextPage,
    this.canLoadNextPage = true,
    this.threshold = 200,
  });

  final Widget child;
  final VoidCallback onLoadNextPage;

  final bool canLoadNextPage;

  final double threshold;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (!canLoadNextPage) return false;

    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= 0) return false;
    if (metrics.pixels < metrics.maxScrollExtent - threshold) return false;

    onLoadNextPage();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: child,
    );
  }
}
