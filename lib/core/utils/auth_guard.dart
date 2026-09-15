import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';










bool redirectGuestToLogin(BuildContext context) {
  if (TokenCacheService().hasAccessToken) return false;

  context.pushNamed(AppRoutes.phoneVerificationScreen);
  return true;
}
