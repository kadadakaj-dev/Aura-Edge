import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lighting_controller.dart';

class AuraBackground extends ConsumerStatefulWidget {
  final Widget? child;
  const AuraBackground({super.key, this.child});

  @override
  ConsumerState<AuraBackground> createState() => _AuraBackgroundState();
}

class _AuraBackgroundState extends ConsumerState<AuraBackground> with TickerProviderStateMixin {
  late AnimationController _timerController;
  FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await FragmentProgram.fromAsset('assets/shaders/mesh_gradient.frag');
    if (mounted) {
      setState(() {
        _shader = program.fragmentShader();
      });
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(lightingSettingsProvider);

    return Stack(
      children: [
        if (settings.isMeshBackgroundEnabled && _shader != null)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _timerController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MeshPainter(
                    shader: _shader!,
                    time: _timerController.value * 60,
                    color1: settings.color1,
                    color2: settings.color2,
                  ),
                );
              },
            ),
          )
        else
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(color: Colors.black),
            ),
          ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final Color color1;
  final Color color2;

  _MeshPainter({
    required this.shader,
    required this.time,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, color1.r);
    shader.setFloat(4, color1.g);
    shader.setFloat(5, color1.b);
    shader.setFloat(6, color1.a);
    shader.setFloat(7, color2.r);
    shader.setFloat(8, color2.g);
    shader.setFloat(9, color2.b);
    shader.setFloat(10, color2.a);

    canvas.drawPaint(Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => true;
}
