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

/// The way out of login, back to the screen that started it — the cart a guest
/// tried to check out from, say.
///
/// Called from the top of the flow, the OTP screen or the profile-completion
/// screen that replaced it, with the phone screen underneath: the two pops
/// leave both. Landing anywhere that is not the app — onboarding, splash, or
/// nothing when the boot sent a returning user straight to profile
/// completion — goes to the main screen instead.
void leaveLoginFlow(BuildContext context) {
  final GoRouter router = GoRouter.of(context);

  if (router.canPop()) router.pop();
  if (router.canPop()) router.pop();

  final String? landedOn = router.state.topRoute?.name;
  if (landedOn == null ||
      landedOn == AppRoutes.onBoardingScreen ||
      landedOn == AppRoutes.phoneVerificationScreen ||
      landedOn == AppRoutes.otpVerificationScreen ||
      landedOn == AppRoutes.completeProfileScreen ||
      landedOn == AppRoutes.splashScreen) {
    router.goNamed(AppRoutes.mainScreen);
  }
}
