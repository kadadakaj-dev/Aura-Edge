import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lighting_controller.dart';
import '../../domain/lighting_settings.dart';
import 'package:flutter/scheduler.dart';

class EdgeLightingPreview extends ConsumerStatefulWidget {
  final Widget child;
  const EdgeLightingPreview({super.key, required this.child});

  @override
  ConsumerState<EdgeLightingPreview> createState() => _EdgeLightingPreviewState();
}

class _EdgeLightingPreviewState extends ConsumerState<EdgeLightingPreview> with SingleTickerProviderStateMixin {
  FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    // Schedule initial load after first frame to access ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final initialShader = ref.read(lightingSettingsProvider).activeShader;
        _loadShader(initialShader);
      }
    });

    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      final speed = ref.read(lightingSettingsProvider).animationSpeed;
      setState(() {
        _time += (elapsed.inMicroseconds / 1000000.0) * speed;
      });
    });
    _ticker.start();
  }

  Future<void> _loadShader(String assetPath) async {
    try {
      final program = await FragmentProgram.fromAsset(assetPath);
      if (mounted) {
        setState(() {
          _program = program;
        });
      }
    } catch (e) {
      debugPrint('Error loading shader ($assetPath): $e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for shader changes to dynamically reload the fragment program
    ref.listen<String>(
      lightingSettingsProvider.select((s) => s.activeShader),
      (previous, next) {
        if (previous != next) {
          _loadShader(next);
        }
      },
    );

    final settings = ref.watch(lightingSettingsProvider);

    if (_program == null || !settings.isEnabled) {
      return widget.child;
    }

    return CustomPaint(
      painter: EdgeLightingPainter(
        program: _program!,
        time: _time,
        settings: settings,
      ),
      child: widget.child,
    );
  }
}

class EdgeLightingPainter extends CustomPainter {
  final FragmentProgram program;
  final double time;
  final LightingSettings settings;

  EdgeLightingPainter({
    required this.program,
    required this.time,
    required this.settings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, settings.borderThickness);
    shader.setFloat(4, settings.cornerRadius);
    
    // color1 (RGBA)
    shader.setFloat(5, settings.color1.r);
    shader.setFloat(6, settings.color1.g);
    shader.setFloat(7, settings.color1.b);
    shader.setFloat(8, settings.color1.a);

    // color2 (RGBA)
    shader.setFloat(9, settings.color2.r);
    shader.setFloat(10, settings.color2.g);
    shader.setFloat(11, settings.color2.b);
    shader.setFloat(12, settings.color2.a);

    // cutout_type (float)
    shader.setFloat(13, settings.cutoutType.index.toDouble());
    
    // snake_mode and snake_length
    shader.setFloat(14, settings.isSnakeMode ? 1.0 : 0.0);
    shader.setFloat(15, settings.snakeLength);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant EdgeLightingPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.settings != settings;
  }
}
