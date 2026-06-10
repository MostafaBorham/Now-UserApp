import 'package:nowdelivery_user_app/common/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/common/route/route_guard.dart';

import 'app_routes.dart';

class RouteGuardImp implements RouteGuard {
  RouteGuardImp._internal();

  static final RouteGuardImp _instance = RouteGuardImp._internal();

  factory RouteGuardImp() => _instance;

  @override
  Future<String?> check() async {
    String? redirectRoute;

    redirectRoute = await redirectToRetryConnection();
    if (redirectRoute != null) return redirectRoute;

    redirectRoute = redirectToRefreshSession();
    if (redirectRoute != null) return redirectRoute;

    redirectRoute = redirectToLogin();
    if (redirectRoute != null) return redirectRoute;

    redirectRoute = redirectToRequestPermission();
    if (redirectRoute != null) return redirectRoute;

    redirectRoute = redirectToCompleteOnBoarding();
    if (redirectRoute != null) return redirectRoute;

    return null;
  }

  @override
  String? redirectToCompleteOnBoarding() {
    return null;
  }

  @override
  String? redirectToLogin() {
    return null;
  }

  @override
  String? redirectToRefreshSession() {
    return null;
  }

  @override
  String? redirectToRequestPermission() {
    return null;
  }

  @override
  Future<String?> redirectToRetryConnection() async {
    final bool isConnected = await ConnectionChecker.isConnected;
    print('connected=$isConnected');
    return isConnected ? null : AppRoutes.noInternetScreen;
  }
}
