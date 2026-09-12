import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.notificationPredicate,
  });
  final Widget child;
  final RefreshCallback onRefresh;

  /// Which scroll notifications the pull-to-refresh reacts to. Defaults to the
  /// standard `notification.depth == 0`, which is right for a plain scroll view.
  /// Pass a wider predicate when the child is a [NestedScrollView], whose top
  /// overscroll reaches this indicator at a deeper level than 0 and is otherwise
  /// ignored — the gesture then does nothing. [RefreshIndicator] still only
  /// starts on a vertical pull from the top, so a broad predicate stays safe.
  final ScrollNotificationPredicate? notificationPredicate;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.primary500Main,
      backgroundColor: colors.white,
      notificationPredicate:
          notificationPredicate ?? defaultScrollNotificationPredicate,
      child: child,
    );
  }
}
