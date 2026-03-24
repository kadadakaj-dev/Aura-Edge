import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../lighting_controller.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class TabDashboard extends ConsumerWidget {
  const TabDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(lightingSettingsProvider);
    final controller = ref.read(lightingSettingsProvider.notifier);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AuraEdge Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your dynamic light assistant.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            // Notification Permission Card
            _buildPermissionCard(),
            const SizedBox(height: 24),

            // Live Preview Card (Mocking a mini phone)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: 200,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: settings.color1.withValues(alpha: 0.5), // Matches user current aura
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: settings.color1.withValues(alpha: 0.2), // Dynamic glow
                          blurRadius: 40,
                          spreadRadius: -10,
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.smartphone, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            settings.isEnabled ? 'Aura Active' : 'Aura Paused',
                            style: TextStyle(
                              color: settings.isEnabled ? Colors.greenAccent : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Hero Toggle
            Center(
              child: GestureDetector(
                onTap: () => controller.toggleEnabled(!settings.isEnabled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  decoration: BoxDecoration(
                    color: settings.isEnabled ? Colors.greenAccent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: settings.isEnabled ? Colors.greenAccent : Colors.white24,
                      width: 2,
                    ),
                    boxShadow: settings.isEnabled ? [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: -5,
                      )
                    ] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        settings.isEnabled ? LucideIcons.power : LucideIcons.powerOff, 
                        color: settings.isEnabled ? Colors.greenAccent : Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        settings.isEnabled ? 'AURA ACTIVE' : 'ACTIVATE AURA',
                        style: TextStyle(
                          color: settings.isEnabled ? Colors.greenAccent : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    return FutureBuilder<bool?>(
      future: FlutterOverlayWindow.isPermissionGranted(),
      builder: (context, snapshot) {
        final isGranted = snapshot.data ?? false;
        if (isGranted) return const SizedBox.shrink(); // Hide if permitted to save space

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.alertTriangle, color: Colors.redAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('System Override Required', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Enable "Display over other apps"', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await FlutterOverlayWindow.requestPermission();
                },
                child: const Text('ALLOW', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
