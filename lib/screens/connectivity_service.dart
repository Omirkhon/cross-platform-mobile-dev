import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService with ChangeNotifier {
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  ConnectivityService() {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((result) {
      final offline = result == ConnectivityResult.none;
      if (_isOffline != offline) {
        _isOffline = offline;
        notifyListeners();
      }
    });
  }
}
