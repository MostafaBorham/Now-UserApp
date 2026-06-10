import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionCheckerPlus {
  static final Connectivity _connectivity = Connectivity();
  static Future<ConnectivityResult> get connectionType async {
    final resultList= await _connectivity.checkConnectivity();
    return resultList.first;
  }

  static Stream<List<ConnectivityResult>> connectionStream(){
    return _connectivity.onConnectivityChanged;
  }
}