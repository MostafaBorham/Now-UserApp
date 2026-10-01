import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/chucker_interceptor.dart';
import 'package:nowdelivery_user_app/core/utils/di/service_locator.dart';
import 'package:nowdelivery_user_app/my_app.dart';

import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';
import 'package:nowdelivery_user_app/core/localization/configs.dart';
import 'package:nowdelivery_user_app/core/utils/app_error_handler.dart';

void main() {
  AppErrorHandler.runGuarded(() async {
    try {
      await EasyLocalization.ensureInitialized();
      await SharedPrefManager.init();
      await HiveManager.init();
      await setupServiceLocator();
    } catch (error, stackTrace) {
      // Everything above runs before `runApp`, so an exception here used to
      // leave the process on a blank window — no message, no way out, nothing
      // to tell the user the app had failed rather than frozen. A corrupt Hive
      // box is the realistic cause, which is also why it cannot simply be
      // retried. Say so instead.
      AppErrorHandler.report(error, stackTrace, context: 'bootstrap');
      runApp(const _BootstrapFailureApp());
      return;
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Chucker otherwise records in debug mode only; QA builds are release.
    ChuckerFlutter.showOnRelease = ChuckerInterceptor.enabled;
    runApp(
      DevicePreview(
        enabled: false,
        builder: (context) {
          return LocalizationInit(child: ProviderScope(child: NowUserApp()));
        },
      ),
    );
  });
}

/// Shown when the app cannot start at all.
///
/// Deliberately depends on nothing: localization is one of the things that may
/// have failed, so the copy is hardcoded in both languages rather than run
/// through `.tr()`, and no theme, provider or asset is touched.
class _BootstrapFailureApp extends StatelessWidget {
  const _BootstrapFailureApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'تعذّر بدء التطبيق',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'أعد تشغيل التطبيق، وإذا استمرت المشكلة أعد تثبيته.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  "The app couldn't start",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Restart the app. If this keeps happening, reinstall it.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
