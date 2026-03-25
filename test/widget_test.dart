import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auraedge/features/lighting/presentation/aura_studio_screen.dart';
import 'package:auraedge/features/lighting/presentation/lighting_controller.dart';
import 'package:auraedge/features/lighting/data/lighting_repository.dart';
import 'package:auraedge/features/lighting/domain/lighting_settings.dart';
import 'package:auraedge/core/system_monitor.dart';
import 'package:auraedge/features/auth/data/auth_repository.dart';

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
  testWidgets('AuraEdge settings smoke test', (WidgetTester tester) async {
    // Override dependencies to avoid native calls and complex auth
    await tester.pumpWidget(ProviderScope(
      overrides: [
        lightingRepositoryProvider.overrideWithValue(MockLightingRepository()),
        systemMonitorProvider.overrideWithValue(MockSystemMonitor()),
        authStateProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: const MaterialApp(
        home: AuraStudioScreen(),
      ),
    ));

    // Pump once to allow the AuraBackground shader program to "load" (mocked/empty in tests usually)
    await tester.pump();
    
    // Check for a core piece of UI that should be present in AuraStudioScreen
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
