import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Single, app-wide entry point for uncaught errors.
///
/// Logs every exception to the terminal in a compact format: one line for the
/// error, plus only the stack frames that originate from the app's own code.
/// Repeated identical errors are throttled so the console stays readable when
/// connectivity drops and dozens of image/API requests fail at once.
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

  /// Reports an error caught by hand, through the same throttled log as the
  /// uncaught ones. For failures a caller has to swallow to keep going — the
  /// bootstrap in `main()` being the one that matters, since anything thrown
  /// there happens before there is a UI to show it on.
  static void report(Object error, StackTrace? stack, {String? context}) =>
      _log(error, stack, context: context);

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
