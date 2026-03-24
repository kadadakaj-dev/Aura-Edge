import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  SystemMonitor(this._ref) {
    _initBatteryListener();
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

  void dispose() {
    _batterySubscription?.cancel();
  }
}
