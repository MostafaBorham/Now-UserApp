import 'package:flutter/material.dart';

/// Calls [onLoadNextPage] once the scrollable in [child] gets within
/// [threshold] pixels of its end, so the next page is already on its way by the
/// time the user reaches the bottom.
///
/// Only detects the intent — whether a request actually goes out is up to
/// [canLoadNextPage] and, ultimately, to the view model.
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

  /// When false the scroll position is ignored — nothing more to load, a page
  /// already in flight, or one that failed and is waiting for a retry tap.
  final bool canLoadNextPage;

  /// How far from the end of the scrollable the next page starts loading.
  final double threshold;

  bool _onScrollNotification(ScrollNotification notification) {
    // Ignore notifications bubbling up from nested scrollables.
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
