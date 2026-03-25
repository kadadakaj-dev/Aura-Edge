import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../lighting_controller.dart';

class PermissionsChecker extends ConsumerStatefulWidget {
  const PermissionsChecker({super.key});

  @override
  ConsumerState<PermissionsChecker> createState() => _PermissionsCheckerState();
}

class _PermissionsCheckerState extends ConsumerState<PermissionsChecker> {
  bool _isOverlayGranted = false;
  bool _isBatteryOptimized = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final overlay = await FlutterOverlayWindow.isPermissionGranted();
    final battery = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    
    if (mounted) {
      setState(() {
        _isOverlayGranted = overlay;
        _isBatteryOptimized = !battery;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOverlayGranted && !_isBatteryOptimized) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.shieldAlert, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text(
                'Nastavenia oprávnení',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isOverlayGranted)
            _PermissionTile(
              label: 'Povoliť zobrazenie nad aplikáciami',
              onTap: () async {
                await FlutterOverlayWindow.requestPermission();
                _checkPermissions();
              },
            ),
          if (_isBatteryOptimized)
            _PermissionTile(
              label: 'Vypnúť optimalizáciu batérie',
              onTap: () async {
                await ref.read(lightingSettingsProvider.notifier).requestIgnoreBatteryOptimizations();
                _checkPermissions();
              },
            ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PermissionTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
