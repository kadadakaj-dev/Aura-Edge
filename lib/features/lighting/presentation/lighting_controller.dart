import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/lighting_settings.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'snake_task_handler.dart';
import '../data/lighting_repository.dart';
import '../../../core/system_monitor.dart';

final lightingRepositoryProvider = Provider<LightingRepository>((ref) {
  return FirebaseLightingRepository();
});

final lightingSettingsProvider = NotifierProvider<LightingController, LightingSettings>(() {
  return LightingController();
});

class LightingController extends Notifier<LightingSettings> {
  static const _notificationsChannel = MethodChannel('com.auraedge.app/notifications');
  Timer? _debounceTimer;

  @override
  LightingSettings build() {
    _init();
    _setupNotificationListener();
    
    final repo = ref.read(lightingRepositoryProvider);
    // Listen to remote changes to sync across devices (local takes precedence during active edits)
    repo.watchSettings().listen((settings) {
      if (settings != null && state != settings) {
        state = settings;
      }
    });
    
    // Initial state check
    const initialState = LightingSettings();
    Future.microtask(() {
      _updateAutomationState(initialState);
      ref.read(systemMonitorProvider); // Initialize battery listener
    });
    
    return initialState;
  }

  void _updateAutomationState(LightingSettings currentState) {
    if (currentState.isEnabled && currentState.isSnakeMode) {
      _startAutomationService();
    } else {
      _stopAutomationService();
    }
  }

  Future<void> _startAutomationService() async {
    if (await FlutterForegroundTask.isRunningService) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'aura_edge_snake',
        channelName: 'AuraEdge Snake Automation',
        channelDescription: 'Keeps the neon snake timer alive in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    await FlutterForegroundTask.startService(
      notificationTitle: 'AuraEdge Snake Active',
      notificationText: 'Running automation in the background.',
      callback: startCallback,
    );
  }

  Future<void> _stopAutomationService() async {
    await FlutterForegroundTask.stopService();
  }

  void toggleEnabled(bool value) {
    state = state.copyWith(isEnabled: value);
    _updateAutomationState(state);
    _saveDebounced();
  }

  void updateSpeed(double value) {
    state = state.copyWith(animationSpeed: value);
    _saveDebounced();
  }

  void updateThickness(double value) {
    state = state.copyWith(borderThickness: value);
    _saveDebounced();
  }

  void updateRadius(double value) {
    state = state.copyWith(cornerRadius: value);
    _saveDebounced();
  }

  void updateCutoutType(CutoutType type) {
    state = state.copyWith(cutoutType: type);
    _saveDebounced();
  }

  void updateSnakeMode(bool value) {
    state = state.copyWith(isSnakeMode: value);
    _updateAutomationState(state);
    _saveDebounced();
  }

  void updateActiveShader(String shaderPath) {
    state = state.copyWith(activeShader: shaderPath);
    _saveDebounced();
  }

  void updateSnakeLength(double value) {
    state = state.copyWith(snakeLength: value);
    _saveDebounced();
  }

  void updatePhysicsMode(PhysicsMode mode) {
    state = state.copyWith(physicsMode: mode);
    _saveDebounced();
  }

  void updateAccelerationFactor(double value) {
    state = state.copyWith(accelerationFactor: value);
    _saveDebounced();
  }

  void _init() async {
    final repo = ref.read(lightingRepositoryProvider);
    final settings = await repo.getSettings();
    state = settings;
    _updateAutomationState(settings);
  }

  void toggleAod(bool value) {
    state = state.copyWith(isAodEnabled: value);
    _saveDebounced();
  }

  void _setupNotificationListener() {
    _notificationsChannel.setMethodCallHandler((call) async {
       if (call.method == 'onNotification' && state.isNotificationPulseEnabled) {
         _triggerPulse();
       }
    });
  }

  void _triggerPulse() async {
    // Save original state
    final originalSettings = state;
    
    // Intense Pulse: Max thickness, fast speed, bright colors (temporarily)
    state = state.copyWith(
      borderThickness: 40.0,
      animationSpeed: 5.0,
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    // Revert to original thickness and speed
    state = state.copyWith(
      borderThickness: originalSettings.borderThickness,
      animationSpeed: originalSettings.animationSpeed,
    );
  }

  void toggleNotificationPulse(bool enabled) {
    state = state.copyWith(isNotificationPulseEnabled: enabled);
    _saveDebounced();
  }

  void toggleMeshBackground(bool enabled) {
    state = state.copyWith(isMeshBackgroundEnabled: enabled);
    _saveDebounced();
  }

  Future<void> requestNotificationAccess() async {
    const channel = MethodChannel('com.auraedge.app/screen_state');
    await channel.invokeMethod('requestNotificationAccess');
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    const channel = MethodChannel('com.auraedge.app/screen_state');
    try {
      await channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      debugPrint('Error requesting battery optimization: $e');
    }
  }

  void _saveDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(lightingRepositoryProvider).saveSettings(state);
    });
  }
}
