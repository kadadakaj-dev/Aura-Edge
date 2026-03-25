import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../lighting_controller.dart';
import '../widgets/permissions_checker.dart';

class TabDashboard extends ConsumerWidget {
  const TabDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(lightingSettingsProvider);
    final controller = ref.read(lightingSettingsProvider.notifier);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
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
                'Váš inteligentný svetelný asistent.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              
              const PermissionsChecker(),
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
                          color: settings.color1.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: settings.color1.withValues(alpha: 0.2),
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

              const SizedBox(height: 48),

              // Notification Pulse Section
              _buildFeatureTile(
                title: 'Pulzujúce Notifikácie',
                subtitle: 'Okraje prebliknú pri prichádzajúcej správe.',
                icon: LucideIcons.bellRing,
                value: settings.isNotificationPulseEnabled,
                onChanged: controller.toggleNotificationPulse,
              ),

              const SizedBox(height: 16),

              // Premium Background Section
              _buildFeatureTile(
                title: 'Prémiové Pozadie',
                subtitle: 'Dynamický Mesh Gradient (Premium) / Čistá čierna (AMOLED).',
                icon: LucideIcons.sparkles,
                value: settings.isMeshBackgroundEnabled,
                onChanged: controller.toggleMeshBackground,
              ),

              const SizedBox(height: 16),

              // Permission Button
              Center(
                child: TextButton.icon(
                  onPressed: controller.requestNotificationAccess,
                  icon: const Icon(LucideIcons.unlock, size: 18, color: Colors.greenAccent),
                  label: const Text(
                    'POVOLIŤ PRÍSTUP K NOTIFIKÁCIÁM',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.greenAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.greenAccent,
                activeTrackColor: Colors.greenAccent.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
