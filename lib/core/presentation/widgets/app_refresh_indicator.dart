import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/dio/deduping_dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The app's pull-to-refresh.
///
/// A pull always reaches the server: reads answered from memory a moment ago
/// (see [DedupingDio]) are forgotten first. Once a refresh ends, pulling does
/// nothing — no spinner — for [DedupingDio.reuseWindow], so dragging again and
/// again can't push the screen's reads into the server's rate limit.
class AppRefreshIndicator extends StatefulWidget {
  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.notificationPredicate,
    this.edgeOffset = 0,
  });
  final Widget child;
  final RefreshCallback onRefresh;
  final double edgeOffset;

  /// Which scroll notifications the pull-to-refresh reacts to. Defaults to the
  /// standard `notification.depth == 0`, which is right for a plain scroll view.
  /// Pass a wider predicate when the child is a [NestedScrollView], whose top
  /// overscroll reaches this indicator at a deeper level than 0 and is otherwise
  /// ignored — the gesture then does nothing. [RefreshIndicator] still only
  /// starts on a vertical pull from the top, so a broad predicate stays safe.
  final ScrollNotificationPredicate? notificationPredicate;

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> {
  /// Runs for [DedupingDio.reuseWindow] after a refresh ends; pulls are
  /// ignored while it does.
  Timer? _cooldown;

  @override
  void dispose() {
    _cooldown?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    DioFactory.forgetRecentReads();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) _cooldown = Timer(DedupingDio.reuseWindow, () {});
    }
  }

  bool _acceptsPull(ScrollNotification notification) =>
      !(_cooldown?.isActive ?? false) &&
      (widget.notificationPredicate ?? defaultScrollNotificationPredicate)(
        notification,
      );

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return RefreshIndicator(
      edgeOffset: widget.edgeOffset,
      onRefresh: _refresh,
      color: colors.primary500Main,
      backgroundColor: colors.white,
      notificationPredicate: _acceptsPull,
      child: widget.child,
    );
  }
}
