import 'package:flutter/material.dart';

enum CutoutType { defaultType, notch, hole, infinity }

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
    );
  }
}
