import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'widgets/edge_lighting_preview.dart';
import 'tabs/tab_dashboard.dart';
import 'tabs/tab_studio.dart';
import 'tabs/tab_triggers.dart';
import 'tabs/tab_discovery.dart';
import 'widgets/aura_background.dart';

class AuraStudioScreen extends StatefulWidget {
  const AuraStudioScreen({super.key});

  @override
  State<AuraStudioScreen> createState() => _AuraStudioScreenState();
}

class _AuraStudioScreenState extends State<AuraStudioScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const TabDashboard(),
    const TabStudio(),
    const TabTriggers(),
    const TabDiscovery(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuraBackground(
        child: EdgeLightingPreview(
          child: Stack(
            children: [
              // Active Tab Content
              IndexedStack(
                index: _currentIndex,
                children: _tabs,
              ),
              
              // Glassmorphism Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: BottomNavigationBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        type: BottomNavigationBarType.fixed,
                        currentIndex: _currentIndex,
                        selectedItemColor: Colors.greenAccent,
                        unselectedItemColor: Colors.white54,
                        showSelectedLabels: true,
                        showUnselectedLabels: true,
                        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        unselectedLabelStyle: const TextStyle(fontSize: 11),
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        items: const [
                          BottomNavigationBarItem(
                            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.home)),
                            activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.home, color: Colors.greenAccent)),
                            label: 'Dashboard',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.sliders)),
                            activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.sliders, color: Colors.greenAccent)),
                            label: 'Studio',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.zap)),
                            activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.zap, color: Colors.greenAccent)),
                            label: 'Triggers',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.globe)),
                            activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(LucideIcons.globe, color: Colors.greenAccent)),
                            label: 'Discovery',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
