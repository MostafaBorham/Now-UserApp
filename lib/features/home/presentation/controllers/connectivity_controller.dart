import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';

/// `true` while the device can reach the network, `false` when offline.
///
/// Seeds with the current state (the underlying status stream only fires on
/// change, so without a seed it would stay unknown until connectivity flips),
/// then tracks every change. Drives the home "showing saved content" cue and
/// the refresh-on-reconnect. Consumers should treat a null value (before the
/// seed resolves) as connected so the cue never flashes on start.
final isConnectedProvider = StreamProvider.autoDispose<bool>((Ref ref) async* {
  yield await ConnectionChecker.isConnected;
  yield* ConnectionChecker.isConnectedStream();
});
