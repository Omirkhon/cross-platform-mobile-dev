import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService with ChangeNotifier {
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    // Check initial state
    final result = await Connectivity().checkConnectivity();
    _updateStatus(result);

    // Listen for changes
    Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(ConnectivityResult result) {
    final offline = result == ConnectivityResult.none;
    if (_isOffline != offline) {
      _isOffline = offline;
      notifyListeners();
    }
  }

  Future<bool> checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    _isOffline = result == ConnectivityResult.none;
    notifyListeners();
    return !_isOffline;
  }
}