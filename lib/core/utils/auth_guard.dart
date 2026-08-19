import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

/// Sends a guest to phone verification instead of running a login-only action.
///
/// Returns `true` when the tap was consumed by the redirect (the session is a
/// guest), `false` when the caller may proceed (a logged-in user). Mirrors the
/// route-level `_redirectToLogin`, but for in-widget actions that no route
/// redirect can cover (e.g. add-to-cart from a product card).
///
/// Uses the same source of truth as the route guard — a cached access token
/// means a logged-in user — so both agree on who is a guest.
bool redirectGuestToLogin(BuildContext context) {
  if (TokenCacheService().hasAccessToken) return false;

  context.pushNamed(AppRoutes.phoneVerificationScreen);
  return true;
}
