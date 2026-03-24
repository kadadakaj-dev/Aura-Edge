import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../lighting_controller.dart';
import '../../domain/lighting_settings.dart';

class TabStudio extends ConsumerWidget {
  const TabStudio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(lightingSettingsProvider);
    final controller = ref.read(lightingSettingsProvider.notifier);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Text(
                'Aura Studio',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionWrap(
              title: 'Patterns (Shaders)',
              icon: LucideIcons.palette,
              child: _buildShaderSelector(settings, controller),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionWrap(
              title: 'Geometry',
              icon: LucideIcons.box,
              child: Column(
                children: [
                  _buildSlider(
                    label: 'Thickness',
                    value: settings.borderThickness,
                    min: 2.0,
                    max: 40.0,
                    onChanged: controller.updateThickness,
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    label: 'Radius',
                    value: settings.cornerRadius,
                    min: 0.0,
                    max: 150.0,
                    onChanged: controller.updateRadius,
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    label: 'Speed',
                    value: settings.animationSpeed,
                    min: 0.1,
                    max: 5.0,
                    onChanged: controller.updateSpeed,
                  ),
                  if (settings.isSnakeMode) ...[
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: 'Snake Tail',
                      value: settings.snakeLength,
                      min: 0.05,
                      max: 0.8,
                      onChanged: controller.updateSnakeLength,
                    ),
                  ],
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionWrap(
              title: 'Cutout Type',
              icon: LucideIcons.scissors,
              child: _buildCutoutSelector(settings, controller),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ), // Bottom padding for nav bar
        ],
      ),
    );
  }

  Widget _buildSectionWrap({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
                    Icon(icon, color: Colors.greenAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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

  Widget _buildShaderSelector(
    LightingSettings settings,
    LightingController controller,
  ) {
    bool isSnake = settings.isSnakeMode;
    bool isFluid = settings.activeShader == 'assets/shaders/fluid_glow.frag';
    bool isStandard = !isSnake && !isFluid;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildShaderPill(
          label: 'Glow',
          icon: LucideIcons.circle,
          isSelected: isStandard,
          onTap: () {
            controller.updateSnakeMode(false);
            controller.updateActiveShader('assets/shaders/edge_glow.frag');
          },
        ),
        _buildShaderPill(
          label: 'Snake',
          icon: LucideIcons.activity,
          isSelected: isSnake,
          onTap: () {
            controller.updateSnakeMode(true);
            controller.updateActiveShader('assets/shaders/edge_glow.frag');
          },
        ),
        _buildShaderPill(
          label: 'Fluid',
          icon: LucideIcons.waves,
          isSelected: isFluid && !isSnake,
          onTap: () {
            controller.updateSnakeMode(false);
            controller.updateActiveShader('assets/shaders/fluid_glow.frag');
          },
        ),
      ],
    );
  }

  Widget _buildShaderPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.greenAccent : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutoutSelector(
    LightingSettings settings,
    LightingController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: CutoutType.values.map((type) {
        final isSelected = settings.cutoutType == type;
        IconData icon;
        switch (type) {
          case CutoutType.notch:
            icon = LucideIcons.panelTop;
            break;
          case CutoutType.hole:
            icon = LucideIcons.disc;
            break;
          case CutoutType.infinity:
            icon = LucideIcons.circleDot;
            break;
          default:
            icon = LucideIcons.smartphone;
        }

        return GestureDetector(
          onTap: () => controller.updateCutoutType(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.greenAccent : Colors.white24,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.greenAccent : Colors.white54,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.greenAccent,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            overlayColor: Colors.greenAccent.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
