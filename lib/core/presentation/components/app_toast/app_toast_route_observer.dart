import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';








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
