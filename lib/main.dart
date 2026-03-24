import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/lighting/presentation/aura_studio_screen.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/lighting/presentation/widgets/edge_lighting_preview.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: EdgeLightingPreview(
        child: SizedBox.expand(),
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
          return const AuthScreen();
        },
        loading: () => const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(backgroundColor: Colors.black, body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white)))),
      ),
    );
  }
}
