import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Single, app-wide entry point for uncaught errors.
///
/// Wiring this up in `main()` means every exception — whether it comes from
/// the Flutter framework (build/layout/paint), an unhandled `Future`, or any
/// synchronous/asynchronous code running inside the app zone — is logged to
/// the terminal in one consistent place, together with its stack trace.
///
/// Usage (in `main.dart`):
/// ```dart
/// AppErrorHandler.runGuarded(() {
///   // ... bootstrap ...
///   runApp(const MyApp());
/// });
/// ```
abstract final class AppErrorHandler {
  /// Runs [body] inside a guarded zone and installs the global error hooks so
  /// that any exception raised anywhere in the app is printed to the terminal.
  static void runGuarded(void Function() body) {
    runZonedGuarded(
      () {
        WidgetsFlutterBinding.ensureInitialized();

        // Framework errors (build/layout/paint, gesture callbacks, etc.).
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          _log(
            details.exception,
            details.stack,
            context: details.context?.toDescription(),
          );
        };

        // Errors that escape to the platform (async gaps, engine callbacks).
        PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
          _log(error, stack, context: 'PlatformDispatcher');
          return true;
        };

        body();
      },
      // Anything not caught by the two hooks above (e.g. errors thrown from
      // un-awaited futures or timers spawned inside the zone).
      (Object error, StackTrace stack) => _log(error, stack, context: 'Zone'),
    );
  }

  static void _log(Object error, StackTrace? stack, {String? context}) {
    final String where = context == null ? '' : ' [$context]';
    debugPrint('⛔️ Uncaught exception$where: $error');
    debugPrintStack(stackTrace: stack ?? StackTrace.current);
  }
}
