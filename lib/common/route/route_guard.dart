abstract class RouteGuard{
  String? redirectToLogin();
  String? redirectToRequestPermission();
  String? redirectToCompleteOnBoarding();
  Future<String?> redirectToRetryConnection();
  String? redirectToRefreshSession();
  Future<String?> check();
}