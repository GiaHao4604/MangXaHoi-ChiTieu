import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';

class DeviceService {
  final Connectivity _connectivity = Connectivity();
  final Battery _battery = Battery();

  // Stream wifi
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  // Stream pin (fake realtime bằng polling)
  Stream<int> batteryStream() async* {
    while (true) {
      yield await _battery.batteryLevel;
      await Future.delayed(Duration(seconds: 10));
    }
  }

  // Stream thời gian
  Stream<String> timeStream() async* {
    while (true) {
      final now = DateTime.now();
      yield "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      await Future.delayed(Duration(seconds: 1));
    }
  }
}
