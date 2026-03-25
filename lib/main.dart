import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/lighting/presentation/aura_studio_screen.dart';
import 'package:auraedge/features/splash/presentation/splash_screen.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/lighting/presentation/widgets/edge_lighting_preview.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' hide NotificationVisibility;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'features/lighting/presentation/lighting_controller.dart';
import 'features/lighting/data/lighting_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const MethodChannel screenChannel = MethodChannel('com.auraedge.app/screen_state');
  
  screenChannel.setMethodCallHandler((call) async {
    if (call.method == 'onScreenOff') {
      final repo = FirebaseLightingRepository();
      final settings = await repo.getSettings();
      if (settings.isAodEnabled && settings.isEnabled) {
        final bool isActive = await FlutterOverlayWindow.isActive();
        if (!isActive) {
          await FlutterOverlayWindow.showOverlay(
            height: WindowSize.matchParent,
            width: WindowSize.matchParent,
            alignment: OverlayAlignment.center,
            visibility: NotificationVisibility.visibilityPublic,
            flag: OverlayFlag.defaultFlag,
            overlayTitle: "AuraEdge AOD",
            overlayContent: "Neon AOD active",
            enableDrag: false,
          );
        }
      }
    } else if (call.method == 'onUserUnlocked') {
      FlutterOverlayWindow.closeOverlay();
    }
  });

  FlutterForegroundTask.initCommunicationPort();
  
  runApp(
    const ProviderScope(
      child: AuraEdgeApp(),
    ),
  );
}

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OverlayEntryWidget(),
      ),
    ),
  );
}

class OverlayEntryWidget extends ConsumerWidget {
  const OverlayEntryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(lightingSettingsProvider);

    return Scaffold(
      backgroundColor: settings.isAodEnabled ? Colors.black : Colors.transparent,
      body: GestureDetector(
        onDoubleTap: () => FlutterOverlayWindow.closeOverlay(),
        child: const EdgeLightingPreview(
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class AuraEdgeApp extends ConsumerWidget {
  const AuraEdgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'AuraEdge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const AuraStudioScreen();
          }
          return const SplashScreen();
        },
        loading: () => const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(backgroundColor: Colors.black, body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white)))),
      ),
    );
  }
}
