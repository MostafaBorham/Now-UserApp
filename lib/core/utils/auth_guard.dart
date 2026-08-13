import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/local/cache/welcome_cache_service.dart';

/// Sends a guest to phone verification instead of running a login-only action.
///
/// Returns `true` when the tap was consumed by the redirect (the session is a
/// guest), `false` when the caller may proceed (a logged-in user). Mirrors the
/// route-level `_redirectToLogin`, but for in-widget actions that no route
/// redirect can cover (e.g. add-to-cart from a product card).
bool redirectGuestToLogin(BuildContext context) {
  final Map<String, dynamic> tokenData = WelcomeCacheService().getToken();
  final bool isGuest = tokenData[CacheKeys.isGuest] as bool? ?? true;

  if (isGuest) {
    context.pushNamed(AppRoutes.phoneVerificationScreen);
    return true;
  }

  return false;
}
