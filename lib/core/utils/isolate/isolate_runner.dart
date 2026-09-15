import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

abstract final class IsolateRunner {
  static Future<R> run<R>(FutureOr<R> Function() computation) {
    if (kIsWeb) {
      return Future<R>.sync(computation);
    }
    return Isolate.run<R>(computation);
  }

  static Future<R> parseJson<R>(
    String source,
    R Function(Object? decoded) map,
  ) {
    return run<R>(() => map(jsonDecode(source)));
  }
}
