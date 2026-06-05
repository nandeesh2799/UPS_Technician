import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) || 
           result.contains(ConnectivityResult.wifi) || 
           result.contains(ConnectivityResult.ethernet);
  }
}
