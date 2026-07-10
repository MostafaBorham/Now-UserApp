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

  static Future<bool> get isConnected => _connectionChecker.hasConnection;

  static Stream<InternetConnectionStatus> connectionStream() {
    /// Take more time
    return _connectionChecker.onStatusChange;
  }
}
