import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auraedge/features/lighting/presentation/lighting_controller.dart';
import 'package:auraedge/features/lighting/data/lighting_repository.dart';
import 'package:auraedge/features/lighting/domain/lighting_settings.dart';
import 'package:auraedge/core/system_monitor.dart';

class MockLightingRepository implements LightingRepository {
  LightingSettings settings = const LightingSettings();

  @override
  Future<void> saveSettings(LightingSettings s) async { settings = s; }
  @override
  Future<LightingSettings> getSettings() async => settings;
  @override
  Stream<LightingSettings?> watchSettings() => Stream.value(null);
}

class MockSystemMonitor implements SystemMonitor {
  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockLightingRepository mockRepo;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    mockRepo = MockLightingRepository();
    container = ProviderContainer(
      overrides: [
        lightingRepositoryProvider.overrideWithValue(mockRepo),
        systemMonitorProvider.overrideWithValue(MockSystemMonitor()),
      ],
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.auraedge.app/screen_state'),
      (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.auraedge.app/notifications'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  group('LightingController Tests', () {
    test('Toggle Enabled should update state and save', () {
      final notifier = container.read(lightingSettingsProvider.notifier);
      notifier.toggleEnabled(true);
      expect(container.read(lightingSettingsProvider).isEnabled, true);
    });

    test('requestIgnoreBatteryOptimizations calls correct MethodChannel', () async {
      final notifier = container.read(lightingSettingsProvider.notifier);
      await notifier.requestIgnoreBatteryOptimizations();
      expect(log, contains(predicate((MethodCall m) => m.method == 'requestIgnoreBatteryOptimizations')));
    });

    test('toggleMeshBackground should update state', () {
      final notifier = container.read(lightingSettingsProvider.notifier);
      notifier.toggleMeshBackground(false);
      expect(container.read(lightingSettingsProvider).isMeshBackgroundEnabled, false);
      notifier.toggleMeshBackground(true);
      expect(container.read(lightingSettingsProvider).isMeshBackgroundEnabled, true);
    });
  });
}
