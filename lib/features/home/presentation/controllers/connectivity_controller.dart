import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';








final isConnectedProvider = StreamProvider.autoDispose<bool>((Ref ref) async* {
  yield await ConnectionChecker.isConnected;
  yield* ConnectionChecker.isConnectedStream();
});
