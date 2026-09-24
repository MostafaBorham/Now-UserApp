import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/token_refresh_interceptor.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/theme_manager.dart';
import 'package:nowdelivery_user_app/core/routing/app_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';

class NowUserApp extends ConsumerWidget {
  const NowUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authSessionProvider, (_, _) {});

    // Wired here because this is the only place holding a `ref` bound to the
    // tree's ProviderScope. Re-assigning on every build is idempotent, and
    // keeps the closure bound to the current root element if it is ever
    // rebuilt (DevicePreview's builder, hot restart).
    //
    // The interceptor has already cleared the dead tokens by this point, so the
    // session reads back as a guest and `resolveSession` takes the same purge
    // path a manual logout does — no separate forced-logout branch to keep in
    // step with this one.
    TokenRefreshInterceptor.onSessionExpired = () async {
      await ref.read(authSessionProvider.notifier).resolveSession();
      AppRouter.router.goNamed(AppRoutes.onBoardingScreen);
    };

    // The backend translates every error and validation message from this
    // header (`SetLocaleFromHeader`) and answers in English without it. This
    // build re-runs on every locale change, so the header follows the picker.
    DioFactory.getDio().options.headers['lang'] = context.locale.languageCode;

    return MaterialApp.router(
      title: LangKeys.appNameKey.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      darkTheme: AppThemes.getDarkModeTheme(),
      locale: context.locale,
      builder: DevicePreview.appBuilder,
      theme: AppThemes.getLightModeTheme(),
      themeMode: ThemeManager.appThemeMode,
      routerConfig: AppRouter.router,
    );
  }
}
