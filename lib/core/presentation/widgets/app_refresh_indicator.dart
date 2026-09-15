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
