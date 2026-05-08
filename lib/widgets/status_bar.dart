import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  late final Stream<List<ConnectivityResult>> _connectivityStream;
  late final Stream<int> _batteryStream;
  late final Stream<BatteryState> _batteryStateStream;
  late final Stream<String> _timeStream;

  @override
  void initState() {
    super.initState();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _batteryStream = _createBatteryStream();
    _batteryStateStream = _battery.onBatteryStateChanged;
    _timeStream = _createTimeStream();
  }

  Stream<int> _createBatteryStream() async* {
    while (true) {
      try {
        yield await _battery.batteryLevel;
      } catch (_) {
        yield 100;
      }
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }

  Stream<String> _createTimeStream() async* {
    while (true) {
      final now = DateTime.now();
      yield '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  int _getSignalLevel(ConnectivityResult? result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return 3;
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        return 4;
      case ConnectivityResult.none:
      case null:
        return 0;
      default:
        return 1;
    }
  }

  IconData _getWifiIcon(ConnectivityResult? result) {
    if (result == ConnectivityResult.none || result == null) {
      return Icons.signal_wifi_off;
    }
    return Icons.wifi;
  }

  ConnectivityResult? _selectConnectivity(List<ConnectivityResult>? results) {
    if (results == null || results.isEmpty) {
      return null;
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    }

    if (results.contains(ConnectivityResult.vpn)) {
      return ConnectivityResult.vpn;
    }

    return results.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<String>(
              stream: _timeStream,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? '--:--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                );
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<List<ConnectivityResult>>(
                  stream: _connectivityStream,
                  builder: (context, snapshot) {
                    final connection = _selectConnectivity(snapshot.data);
                    return _SignalBarsIcon(level: _getSignalLevel(connection));
                  },
                ),
                const SizedBox(width: 8),
                StreamBuilder<List<ConnectivityResult>>(
                  stream: _connectivityStream,
                  builder: (context, snapshot) {
                    return Icon(
                      _getWifiIcon(_selectConnectivity(snapshot.data)),
                      color: Colors.white,
                      size: 20,
                    );
                  },
                ),
                const SizedBox(width: 10),
                StreamBuilder<BatteryState>(
                  stream: _batteryStateStream,
                  builder: (context, stateSnapshot) {
                    final batteryState =
                        stateSnapshot.data ?? BatteryState.unknown;
                    return StreamBuilder<int>(
                      stream: _batteryStream,
                      builder: (context, levelSnapshot) {
                        final level = levelSnapshot.data ?? 100;
                        return _BatteryHorizontalIcon(
                          level: level,
                          batteryState: batteryState,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalBarsIcon extends StatelessWidget {
  const _SignalBarsIcon({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final normalizedLevel = level.clamp(0, 4);

    return SizedBox(
      width: 18,
      height: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SignalBar(height: 3, active: normalizedLevel >= 1),
          const SizedBox(width: 2),
          _SignalBar(height: 6, active: normalizedLevel >= 2),
          const SizedBox(width: 2),
          _SignalBar(height: 9, active: normalizedLevel >= 3),
          const SizedBox(width: 2),
          _SignalBar(height: 12, active: normalizedLevel >= 4),
        ],
      ),
    );
  }
}

class _SignalBar extends StatelessWidget {
  const _SignalBar({required this.height, required this.active});

  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _BatteryHorizontalIcon extends StatelessWidget {
  const _BatteryHorizontalIcon({
    required this.level,
    required this.batteryState,
  });

  final int level;
  final BatteryState batteryState;

  Color _innerColor(int normalizedLevel, BatteryState state) {
    if (state == BatteryState.charging || state == BatteryState.full) {
      return const Color(0xFF22C55E);
    }

    if (normalizedLevel <= 20) {
      return const Color(0xFFEF4444);
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final normalizedLevel = level.clamp(0, 100);
    final innerColor = _innerColor(normalizedLevel, batteryState);
    final textColor = innerColor == Colors.white ? Colors.black : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 14,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                color: innerColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
              child: Center(
                child: Text(
                  '$normalizedLevel',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 2.2,
          height: 6,
          margin: const EdgeInsets.only(left: 1.4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
