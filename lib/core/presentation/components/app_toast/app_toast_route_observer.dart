import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';

/// A [NavigatorObserver] that dismisses the current [AppToast] on navigation, so
/// a toast never lingers on a page the user has already left (push, pop, replace
/// or remove — screens, bottom sheets and dialogs alike).
///
/// Register it on the root `GoRouter`'s `observers`. [AppToast] itself protects
/// deliberate "show a message, then navigate" flows via a short grace window, so
/// this can safely fire on every route change.
class AppToastRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppToast.dismissForRouteChange();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppToast.dismissForRouteChange();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppToast.dismissForRouteChange();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppToast.dismissForRouteChange();
  }
}
