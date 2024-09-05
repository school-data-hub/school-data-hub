import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectionManager {
  ValueListenable<Stream<List<ConnectivityResult>>> get connectivity =>
      _connectivity;

  final _connectivity = ValueNotifier<Stream<List<ConnectivityResult>>>(
      Connectivity().onConnectivityChanged);

  ConnectionManager();

  Future checkConnectivity() async {
    final connection = await (Connectivity().checkConnectivity());
    return connection;
    // //_connectivity.value = connection;
  }
}
