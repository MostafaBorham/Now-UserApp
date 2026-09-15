import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/dio_constants.dart';

class ConnectionChecker {
  ConnectionChecker._();





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

    return _connectionChecker.onStatusChange;
  }





  static Stream<bool> isConnectedStream() => _connectionChecker.onStatusChange
      .map((InternetConnectionStatus status) =>
          status == InternetConnectionStatus.connected);
}
