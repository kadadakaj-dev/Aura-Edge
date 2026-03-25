import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:flutter/foundation.dart';
import '../features/lighting/presentation/lighting_controller.dart';

final systemMonitorProvider = Provider<SystemMonitor>((ref) {
  final monitor = SystemMonitor(ref);
  ref.onDispose(() => monitor.dispose());
  return monitor;
});

class SystemMonitor {
  final Ref _ref;
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<int>? _proximitySubscription;
  bool _isNear = false;

  SystemMonitor(this._ref) {
    _initBatteryListener();
    _initProximityListener();
  }

  void _initBatteryListener() {
    _batterySubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      final lightingController = _ref.read(lightingSettingsProvider.notifier);
      final currentSettings = _ref.read(lightingSettingsProvider);

      if (state == BatteryState.charging) {
        // Automatically switch to Fluid Shader when charging
        if (currentSettings.activeShader != 'assets/shaders/fluid_glow.frag') {
          lightingController.updateActiveShader('assets/shaders/fluid_glow.frag');
        }
      } else if (state == BatteryState.discharging || state == BatteryState.full) {
        // Revert to Snake shader if unplugged, or default
        if (currentSettings.activeShader == 'assets/shaders/fluid_glow.frag') {
          lightingController.updateActiveShader('assets/shaders/edge_glow.frag');
        }
      }
    });
  }

  void _initProximityListener() {
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      // 1 = Far, 0 = Near
      _isNear = event == 0;
      final settings = _ref.read(lightingSettingsProvider);
      final controller = _ref.read(lightingSettingsProvider.notifier);

      if (_isNear && settings.isAodEnabled) {
         debugPrint('POCKET MODE: Near detected, pausing AOD lighting.');
         if (settings.isEnabled) {
           controller.toggleEnabled(false);
         }
      } else if (!_isNear && settings.isAodEnabled) {
         debugPrint('POCKET MODE: Far detected, resuming AOD lighting.');
         if (!settings.isEnabled) {
           controller.toggleEnabled(true);
         }
      }
    });
  }

  void dispose() {
    _batterySubscription?.cancel();
    _proximitySubscription?.cancel();
  }
}
