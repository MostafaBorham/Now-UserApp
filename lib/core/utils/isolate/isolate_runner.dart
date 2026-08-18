import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// Offloads pure-Dart, CPU-bound work to a background isolate so it never
/// blocks the UI thread.
///
/// Use ONLY when all of these hold (see the isolate-usage policy):
/// - the work is pure Dart and CPU-bound (synchronously heavy — a big JSON
///   parse, a large list transform, hashing, compression) and long enough that
///   a dropped frame is a real risk;
/// - its inputs and result are *sendable* between isolates — primitives,
///   `String`, `TypedData`/`Uint8List`, or simple `Map`/`List` of those;
/// - the UI does not need the result synchronously to keep rendering.
///
/// Do NOT use it for platform-channel/plugin calls (geolocation, geocoding,
/// Dio, plugin file IO — already async off the Dart thread, and unavailable on
/// a spawned isolate), for `dart:ui` work (`Canvas`, `Picture`,
/// `Picture.toImage`, `flutter_svg`), for `rootBundle`/asset loading, or for
/// trivially small work where the spawn + argument-copy overhead outweighs the
/// gain.
abstract final class IsolateRunner {
  /// Runs [computation] on a background isolate and returns its result.
  ///
  /// [computation] is shipped to the other isolate, so it must be a
  /// top-level/static function or a closure that captures only sendable values —
  /// it cannot close over a `BuildContext`, a plugin handle, or any `dart:ui`
  /// object.
  ///
  /// On the web (no isolate support) it runs inline on the current thread, so
  /// call sites stay identical across platforms.
  static Future<R> run<R>(FutureOr<R> Function() computation) {
    if (kIsWeb) {
      return Future<R>.sync(computation);
    }
    return Isolate.run<R>(computation);
  }

  /// Decodes [source] as JSON off the UI thread, then maps the decoded tree to
  /// [R] with [map] — decode and map run together in one background isolate, so
  /// a large model list is built without touching the main thread.
  ///
  /// Pass the raw JSON body (configure the request/Dio to hand back the
  /// unparsed string), otherwise the expensive decode has already happened on
  /// the main thread and only the cheap mapping is offloaded.
  ///
  /// [map] runs inside the isolate: keep it a top-level/static function, or a
  /// closure over sendable data only. Typical use in a repo:
  /// ```dart
  /// final products = await IsolateRunner.parseJson(
  ///   rawJsonBody,
  ///   (json) => (json as List)
  ///       .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
  ///       .toList(),
  /// );
  /// ```
  static Future<R> parseJson<R>(
    String source,
    R Function(Object? decoded) map,
  ) {
    return run<R>(() => map(jsonDecode(source)));
  }
}
