import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionChecker {
  static final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.instance;
  static Future<bool> get isConnected => _connectionChecker.hasConnection;

  static Stream<InternetConnectionStatus> connectionStream() {
    /// Take more time
    return _connectionChecker.onStatusChange;
  }
}
