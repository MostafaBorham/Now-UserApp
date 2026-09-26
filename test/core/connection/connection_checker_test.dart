import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';

void main() {
  group('ConnectionChecker.anyReachable', () {
    test('answers on the first success without waiting for a hung host',
        () async {
      final Completer<bool> hung = Completer<bool>();

      final bool connected = await ConnectionChecker.anyReachable(
        <Future<bool>>[hung.future, Future<bool>.value(true)],
      ).timeout(const Duration(seconds: 1));

      expect(connected, isTrue);
    });

    test('is connected when only one host is reachable', () async {
      expect(
        await ConnectionChecker.anyReachable(<Future<bool>>[
          Future<bool>.value(false),
          Future<bool>.value(true),
          Future<bool>.value(false),
        ]),
        isTrue,
      );
    });

    test('is offline only once every host has failed, errors included',
        () async {
      expect(
        await ConnectionChecker.anyReachable(<Future<bool>>[
          Future<bool>.value(false),
          Future<bool>.error(Exception('socket')),
        ]),
        isFalse,
      );
    });
  });
}
