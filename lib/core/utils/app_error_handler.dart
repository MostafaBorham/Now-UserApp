import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

abstract final class AppErrorHandler {
  static void runGuarded(void Function() body) {
    runZonedGuarded(
      () {
        WidgetsFlutterBinding.ensureInitialized();

        FlutterError.onError = (FlutterErrorDetails details) {
          _log(
            details.exception,
            details.stack,
            context: details.context?.toDescription(),
          );
        };

        PlatformDispatcher.instance.onError =
            (Object error, StackTrace stack) {
          _log(error, stack, context: 'PlatformDispatcher');
          return true;
        };

        body();
      },
      (Object error, StackTrace stack) => _log(error, stack, context: 'Zone'),
    );
  }

  static final Map<String, DateTime> _recentErrors = {};
  static const Duration _throttleWindow = Duration(seconds: 30);

  static void _log(Object error, StackTrace? stack, {String? context}) {
    final String key = '$context:$error';

    final now = DateTime.now();
    final lastSeen = _recentErrors[key];
    if (lastSeen != null && now.difference(lastSeen) < _throttleWindow) return;
    _recentErrors[key] = now;

    if (_recentErrors.length > 50) {
      final cutoff = now.subtract(const Duration(minutes: 1));
      _recentErrors.removeWhere((_, time) => time.isBefore(cutoff));
    }

    final String where = context == null ? '' : ' [$context]';
    final String appFrame = _firstAppFrame(stack);
    debugPrint('⛔️$where $error${appFrame.isNotEmpty ? '\n   at $appFrame' : ''}');
  }

  static String _firstAppFrame(StackTrace? stack) {
    if (stack == null) return '';
    for (final line in stack.toString().split('\n')) {
      if (line.contains('package:nowdelivery_user_app/')) {
        return line.trim().replaceFirst(RegExp(r'^#\d+\s*'), '');
      }
    }
    return '';
  }
}
