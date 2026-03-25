import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/presentation/auth_screen.dart'; // Adjust path if needed

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _burstController;
  late AnimationController _logoController;
  
  bool _showEdges = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Phase 1: Pulsing Heart (Wait 2s)
    await Future.delayed(const Duration(seconds: 2));
    
    // Phase 2: Burst Explosion
    await _burstController.forward();
    setState(() => _showEdges = true);
    
    // Phase 3: Logo Reveal
    await _logoController.forward();
    
    // Phase 4: Delay for impact and navigate
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
       // Root deciding logic happens in main.dart, we just finish splash here
       // For now, we'll callback or handle it in main.dart by watching a provider
       // Navigating to AuthScreen just for demonstration if needed, 
       // but main.dart should handle the switch.
       Navigator.of(context).pushReplacement(
         PageRouteBuilder(
           pageBuilder: (_, __, ___) => const AuthScreen(),
           transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
           transitionDuration: const Duration(milliseconds: 800),
         )
       );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _burstController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          if (_showEdges)
            _buildEdgeGlow(),

          // Particles
          Center(
            child: CustomPaint(
              painter: NexusPainter(
                pulse: _pulseController.value,
                burst: _burstController.value,
              ),
              child: const SizedBox(width: 300, height: 300),
            ),
          ),

          // Logo
          Center(
            child: FadeTransition(
              opacity: _logoController,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.zap, color: Colors.greenAccent, size: 80),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent, Colors.greenAccent],
                        stops: [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                      child: const Text(
                        'AuraEdge',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'STAY IN THE LIGHT',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                        letterSpacing: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdgeGlow() {
    // This is a placeholder for the actual edge glowing logic
    // We'll use a container with a multi-layered glow to simulate the "Nexus hit"
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withValues(alpha: 0.2),
            blurRadius: 100,
            spreadRadius: 20,
          )
        ],
      ),
    );
  }
}

class NexusPainter extends CustomPainter {
  final double pulse;
  final double burst;

  NexusPainter({required this.pulse, required this.burst});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.greenAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // Heart Pulse
    if (burst < 0.1) {
      canvas.drawCircle(center, 20 + (pulse * 15), paint);
    }

    // Explosion Rays
    if (burst > 0) {
      final rayCount = 12;
      for (int i = 0; i < rayCount; i++) {
        final angle = (i * 2 * math.pi / rayCount) + (burst * math.pi / 2);
        final length = 400 * burst;
        final end = center + Offset(math.cos(angle) * length, math.sin(angle) * length);
        
        canvas.drawLine(
          center,
          end,
          Paint()
            ..shader = RadialGradient(
              colors: [Colors.greenAccent, Colors.transparent],
            ).createShader(Rect.fromCircle(center: center, radius: 400 * burst))
            ..strokeWidth = 4 * (1.0 - burst)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant NexusPainter oldDelegate) => true;
}
