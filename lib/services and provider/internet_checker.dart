import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetChecker {
  static final Connectivity _connectivity = Connectivity();
  static late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  static List<ConnectivityResult> _connectivityResult = [];

  // Initialize and listen to connectivity changes
  static void init(Function(bool) onConnectivityChanged) {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _connectivityResult = results;
      bool isConnected = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
      onConnectivityChanged(isConnected);
    });
  }

  // Get the current connectivity status
  static Future<bool> hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
  }

  // Dispose the subscription when not needed
  static void dispose() {
    _connectivitySubscription.cancel();
  }
}
