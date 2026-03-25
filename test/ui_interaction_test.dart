import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auraedge/features/lighting/presentation/tabs/tab_studio.dart';
import 'package:auraedge/features/lighting/presentation/tabs/tab_dashboard.dart';
import 'package:auraedge/features/lighting/presentation/lighting_controller.dart';
import 'package:auraedge/features/lighting/data/lighting_repository.dart';
import 'package:auraedge/features/lighting/domain/lighting_settings.dart';
import 'package:auraedge/features/lighting/presentation/widgets/permissions_checker.dart';
import 'package:auraedge/core/system_monitor.dart';
import 'package:auraedge/features/auth/data/auth_repository.dart';

class MockLightingRepository implements LightingRepository {
  LightingSettings _settings = const LightingSettings(isSnakeMode: true);
  final _controller = StreamController<LightingSettings?>.broadcast();

  MockLightingRepository() {
    _controller.add(_settings);
  }

  LightingSettings get settings => _settings;

  @override
  Future<void> saveSettings(LightingSettings s) async { 
    debugPrint('MOCK REPO: Saved physicsMode = ${s.physicsMode}');
    _settings = s;
    _controller.add(s);
  }

  @override
  Future<LightingSettings> getSettings() async => _settings;
  @override
  Stream<LightingSettings?> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }
}

class MockSystemMonitor implements SystemMonitor {
  @override
  void dispose() {}
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<void> signOut() async {}
  @override
  Future<UserCredential?> signInAnonymously() async => null;
  @override
  Future<UserCredential?> signInWithGoogle() async => null;
  @override
  Stream<User?> get authStateChanges => Stream.value(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.pravera/flutter_foreground_task'),
      (call) async {
        if (call.method == 'isRunningService') return false;
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_overlay_window'),
      (call) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.auraedge.app/notifications'),
      (call) async => null,
    );
  });

  group('UI Widget 1000% Certainty Tests', () {
    testWidgets('TabStudio should toggle physics modes', (WidgetTester tester) async {
      // Increase screen size to see all slivers
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockLightingRepository();
      
      await tester.pumpWidget(ProviderScope(
        overrides: [
          lightingRepositoryProvider.overrideWithValue(mockRepo),
          systemMonitorProvider.overrideWithValue(MockSystemMonitor()),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: TabStudio())),
      ));

      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      final textWidgets = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList();
      debugPrint('TEXT_DUMP: $textWidgets');

      // Check if Snake exists
      expect(find.text('Snake'), findsOneWidget);
      
      // Find Ping-Pong option and scroll into view
      final pingPongFinder = find.text('Ping-Pong');
      await tester.ensureVisible(pingPongFinder);
      await tester.tap(pingPongFinder);
      await tester.pumpAndSettle();
      
      // Wait for debounce timer (500ms in controller)
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      
      // Verify state via repository (since it's saved)
      expect(mockRepo.settings.physicsMode, PhysicsMode.pingPong);
    });

    testWidgets('TabDashboard should show PermissionsChecker', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          lightingRepositoryProvider.overrideWithValue(MockLightingRepository()),
          systemMonitorProvider.overrideWithValue(MockSystemMonitor()),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: TabDashboard())),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(PermissionsChecker), findsOneWidget);
      expect(find.text('AuraEdge Pro'), findsOneWidget);
    });
  });
}
