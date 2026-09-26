import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/dio_constants.dart';

class ConnectionChecker {
  ConnectionChecker._();

  /// The package's default check URLs (dummyapi.online, jsonplaceholder,
  /// fakestoreapi) are unreliable and can report "offline" on a working
  /// connection, so we check against our own API server plus stable hosts.
  /// Any single reachable address counts as connected.
  static final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.createInstance(
    addresses: <AddressCheckOption>[
      AddressCheckOption(uri: Uri.parse(DioConstants.baseUrl)),
      AddressCheckOption(uri: Uri.parse('https://www.google.com')),
      AddressCheckOption(uri: Uri.parse('https://one.one.one.one')),
    ],
  );

  /// Answers as soon as the first address responds. The package's own
  /// `hasConnection` waits for every address, so one host that hangs instead
  /// of failing fast held every repo call for the full check timeout.
  static Future<bool> get isConnected async {
    final bool connected = await anyReachable(
      _connectionChecker.addresses.map((AddressCheckOption address) =>
          _connectionChecker
              .isHostReachable(address)
              .then((AddressCheckResult result) => result.isSuccess)),
    );
    // A success already emits `connected` from `isHostReachable`; the failure
    // has to be emitted here, as `hasConnection` did, to keep the stream live.
    if (!connected) {
      _connectionChecker.emitStatus(InternetConnectionStatus.disconnected);
    }
    return connected;
  }

  /// `true` on the first check that succeeds; `false` only once every check
  /// has failed. A check that throws counts as a failure.
  @visibleForTesting
  static Future<bool> anyReachable(Iterable<Future<bool>> checks) {
    final List<Future<bool>> pending = checks.toList();
    final Completer<bool> result = Completer<bool>();
    int failed = 0;
    for (final Future<bool> check in pending) {
      check.catchError((Object _) => false).then((bool ok) {
        if (result.isCompleted) return;
        if (ok) {
          result.complete(true);
        } else if (++failed == pending.length) {
          result.complete(false);
        }
      });
    }
    return result.future;
  }

  static Stream<InternetConnectionStatus> connectionStream() {
    /// Take more time
    return _connectionChecker.onStatusChange;
  }

  /// [connectionStream] mapped to a plain `bool` (`true` = connected), so
  /// callers don't need to import the `internet_connection_checker` package to
  /// react to connectivity changes. Fires only on change, like the underlying
  /// stream — seed with [isConnected] for the current state.
  static Stream<bool> isConnectedStream() => _connectionChecker.onStatusChange
      .map((InternetConnectionStatus status) =>
          status == InternetConnectionStatus.connected);
}
