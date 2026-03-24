// This is a basic Flutter widget test.
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:auraedge/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auraedge/features/lighting/presentation/lighting_controller.dart';
import 'package:auraedge/features/lighting/data/lighting_repository.dart';
import 'package:auraedge/features/lighting/domain/lighting_settings.dart';

class MockLightingRepository implements LightingRepository {
  @override
  Future<void> saveSettings(LightingSettings settings) async {}
  @override
  Stream<LightingSettings?> watchSettings() => Stream.value(null);
}

void main() {
  testWidgets('AuraEdge settings smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        lightingRepositoryProvider.overrideWithValue(MockLightingRepository()),
      ],
      child: const AuraEdgeApp(),
    ));
    await tester.pump(); // Trigger a frame, but don't wait for the infinite ticker to settle

    // Verify that our main title is present.
    expect(find.text('AuraEdge'), findsOneWidget);
    expect(find.text('Povoliť okrajové svetlo'), findsOneWidget);
  });
}
