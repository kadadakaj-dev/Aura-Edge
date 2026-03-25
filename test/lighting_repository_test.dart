import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:auraedge/features/lighting/domain/lighting_settings.dart';

void main() {
  group('LightingSettings Serialization Tests', () {
    test('Should correctly serialize and deserialize with new fields', () {
      const original = LightingSettings(
        isEnabled: true,
        color1: Color(0xFFFF0000),
        color2: Color(0xFF00FF00),
        borderThickness: 15.0,
        cornerRadius: 30.0,
        animationSpeed: 2.5,
        cutoutType: CutoutType.defaultType,
        isSnakeMode: true,
        snakeLength: 0.4,
        physicsMode: PhysicsMode.pingPong,
        accelerationFactor: 0.15,
        isAodEnabled: true,
      );

      final map = original.toMap();
      final deserialized = LightingSettings.fromMap(map);

      expect(deserialized.isEnabled, original.isEnabled);
      expect(deserialized.color1, original.color1);
      expect(deserialized.color2, original.color2);
      expect(deserialized.borderThickness, original.borderThickness);
      expect(deserialized.physicsMode, PhysicsMode.pingPong);
      expect(deserialized.accelerationFactor, 0.15);
      expect(deserialized.isAodEnabled, true);
    });

    test('Should handle unknown physicsMode gracefully', () {
      final map = {
        'isEnabled': true,
        'color1': 0xFFFF0000,
        'color2': 0xFF00FF00,
        'borderThickness': 10.0,
        'cornerRadius': 20.0,
        'animationSpeed': 1.0,
        'cutoutType': 0,
        'isSnakeMode': true,
        'snakeLength': 0.3,
        'physicsMode': 'unknown', // String fallback
        'accelerationFactor': 0.0,
        'isAodEnabled': false,
      };

      final settings = LightingSettings.fromMap(map);
      expect(settings.physicsMode, PhysicsMode.loop); // Default fallback
    });
  });
}
