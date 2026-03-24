import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TabTriggers extends ConsumerWidget {
  const TabTriggers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: We'll need to expand LightingSettings to store trigger-specific values 
    // for Phase 3. For now, we'll build the UI shell.

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Text(
                'Smart Triggers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: _buildTriggerCard(
              title: 'Battery Aura',
              description: 'Change colors based on battery level.',
              icon: LucideIcons.batteryMedium,
              child: Column(
                children: [
                  _buildTriggerToggle('Alert at 20% (Yellow)', true),
                  _buildTriggerToggle('Alert at 10% (Red)', true),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildTriggerCard(
              title: 'Charging Flow',
              description: 'Liquid animation when plugged in.',
              icon: LucideIcons.zap,
              child: _buildTriggerToggle('Enable Fluid Animation', true),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildTriggerCard(
              title: 'Music Pulse',
              description: 'React to audio amplitude.',
              icon: LucideIcons.music,
              child: _buildTriggerToggle('Pulse with Bass', false),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildTriggerCard(
              title: 'App Alerts',
              description: 'Custom aura for specific apps.',
              icon: LucideIcons.bell,
              child: Column(
                children: [
                  _buildAppItem('Instagram', Colors.purpleAccent),
                  _buildAppItem('WhatsApp', Colors.greenAccent),
                  _buildAppItem('Messenger', Colors.blueAccent),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Add App'),
                  )
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTriggerCard({required String title, required String description, required IconData icon, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.greenAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                          Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTriggerToggle(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Switch(
            value: value,
            onChanged: (v) {},
            activeThumbColor: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildAppItem(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
        ],
      ),
    );
  }
}
