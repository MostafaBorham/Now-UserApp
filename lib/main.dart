import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/utils/di/service_locator.dart';
import 'package:nowdelivery_user_app/my_app.dart';

import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';
import 'package:nowdelivery_user_app/core/localization/configs.dart';
import 'package:nowdelivery_user_app/core/utils/app_error_handler.dart';

void main() {
  AppErrorHandler.runGuarded(() async {
    await EasyLocalization.ensureInitialized();
    await SharedPrefManager.init();
    await HiveManager.init();



    await setupServiceLocator();
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
