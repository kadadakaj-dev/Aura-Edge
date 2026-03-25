import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' hide NotificationVisibility;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SnakeTaskHandler());
}

class SnakeTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final bool isActive = await FlutterOverlayWindow.isActive();
    if (!isActive) {
      await FlutterOverlayWindow.showOverlay(
        height: WindowSize.matchParent,
        width: WindowSize.matchParent,
        alignment: OverlayAlignment.center,
        visibility: NotificationVisibility.visibilityPublic,
        flag: OverlayFlag.defaultFlag,
        overlayTitle: "AuraEdge Snake",
        overlayContent: "Neon Snake animation active",
        enableDrag: false,
      );
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // We use standard Timer instead of repeat event, but can also use this
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isStopService) async {
    _timer?.cancel();
  }

  @override
  void onReceiveData(Object data) {
    // Handle data from main isolate if needed
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop') {
      FlutterOverlayWindow.closeOverlay();
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationDismissed() {}
}
