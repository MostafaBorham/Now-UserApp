import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/local_controller.dart';
import 'package:nowdelivery_user_app/data/datasources/local/cache/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/my_app.dart';

import 'common/localization/configs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // await SharedPrefManager.init();
  // await LocalController.getCurrentLocale();
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
  ]).then(
    (_) => runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        // enabled: false,
        builder: (context) {
          return LocalizationInit(
          child: ProviderScope(
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => NowUserApp(),
            ),
          ),
        );
        },
      ),
    ),
  );
}
