import 'package:flutter/material.dart';

enum CutoutType { defaultType, notch, hole, infinity }
enum PhysicsMode { loop, pingPong, turboAcceleration }

class LightingSettings {
  final bool isEnabled;
  final double animationSpeed;
  final double borderThickness;
  final double cornerRadius;
  final CutoutType cutoutType;
  final Color color1;
  final Color color2;
  final bool isSnakeMode;
  final double snakeLength;
  final String activeShader;
  final PhysicsMode physicsMode;
  final double accelerationFactor;
  final bool isNotificationPulseEnabled;
  final bool isAodEnabled;
  final bool isMeshBackgroundEnabled;

  const LightingSettings({
    this.isEnabled = true,
    this.animationSpeed = 1.0,
    this.borderThickness = 10.0,
    this.cornerRadius = 40.0,
    this.cutoutType = CutoutType.defaultType,
    this.color1 = Colors.blue,
    this.color2 = Colors.purple,
    this.isSnakeMode = false,
    this.snakeLength = 0.2,
    this.activeShader = 'assets/shaders/edge_glow.frag',
    this.physicsMode = PhysicsMode.loop,
    this.accelerationFactor = 1.1,
    this.isNotificationPulseEnabled = true,
    this.isAodEnabled = false,
    this.isMeshBackgroundEnabled = true,
  });

  LightingSettings copyWith({
    bool? isEnabled,
    double? animationSpeed,
    double? borderThickness,
    double? cornerRadius,
    CutoutType? cutoutType,
    Color? color1,
    Color? color2,
    bool? isSnakeMode,
    double? snakeLength,
    String? activeShader,
    PhysicsMode? physicsMode,
    double? accelerationFactor,
    bool? isNotificationPulseEnabled,
    bool? isAodEnabled,
    bool? isMeshBackgroundEnabled,
  }) {
    return LightingSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      borderThickness: borderThickness ?? this.borderThickness,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      cutoutType: cutoutType ?? this.cutoutType,
      color1: color1 ?? this.color1,
      color2: color2 ?? this.color2,
      isSnakeMode: isSnakeMode ?? this.isSnakeMode,
      snakeLength: snakeLength ?? this.snakeLength,
      activeShader: activeShader ?? this.activeShader,
      physicsMode: physicsMode ?? this.physicsMode,
      accelerationFactor: accelerationFactor ?? this.accelerationFactor,
      isNotificationPulseEnabled: isNotificationPulseEnabled ?? this.isNotificationPulseEnabled,
      isAodEnabled: isAodEnabled ?? this.isAodEnabled,
      isMeshBackgroundEnabled: isMeshBackgroundEnabled ?? this.isMeshBackgroundEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'animationSpeed': animationSpeed,
      'borderThickness': borderThickness,
      'cornerRadius': cornerRadius,
      'cutoutType': cutoutType.name,
      'color1': color1.toARGB32(),
      'color2': color2.toARGB32(),
      'isSnakeMode': isSnakeMode,
      'snakeLength': snakeLength,
      'activeShader': activeShader,
      'physicsMode': physicsMode.name,
      'accelerationFactor': accelerationFactor,
      'isNotificationPulseEnabled': isNotificationPulseEnabled,
      'isAodEnabled': isAodEnabled,
      'isMeshBackgroundEnabled': isMeshBackgroundEnabled,
    };
  }

  factory LightingSettings.fromMap(Map<String, dynamic> map) {
    return LightingSettings(
      isEnabled: map['isEnabled'] ?? true,
      animationSpeed: (map['animationSpeed'] ?? 1.0).toDouble(),
      borderThickness: (map['borderThickness'] ?? 10.0).toDouble(),
      cornerRadius: (map['cornerRadius'] ?? 40.0).toDouble(),
      cutoutType: CutoutType.values.firstWhere(
        (e) => e.name == map['cutoutType'],
        orElse: () => CutoutType.defaultType,
      ),
      color1: map['color1'] != null ? Color(map['color1']) : Colors.blue,
      color2: map['color2'] != null ? Color(map['color2']) : Colors.purple,
      isSnakeMode: map['isSnakeMode'] ?? false,
      snakeLength: (map['snakeLength'] ?? 0.2).toDouble(),
      activeShader: map['activeShader'] ?? 'assets/shaders/edge_glow.frag',
      physicsMode: PhysicsMode.values.firstWhere(
        (e) => e.name == map['physicsMode'],
        orElse: () => PhysicsMode.loop,
      ),
      accelerationFactor: (map['accelerationFactor'] ?? 1.1).toDouble(),
      isNotificationPulseEnabled: map['isNotificationPulseEnabled'] ?? true,
      isAodEnabled: map['isAodEnabled'] ?? false,
      isMeshBackgroundEnabled: map['isMeshBackgroundEnabled'] ?? true,
    );
  }
}
