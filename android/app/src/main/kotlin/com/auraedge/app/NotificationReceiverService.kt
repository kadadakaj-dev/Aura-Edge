package com.auraedge.app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.dart.DartExecutor
import android.util.Log

class NotificationReceiverService : NotificationListenerService() {
    private val CHANNEL = "com.auraedge.app/notifications"
    private var methodChannel: MethodChannel? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return
        
        // Don't pulse for our own app notifications (if any)
        if (sbn.packageName == packageName) return

        Log.d("AuraEdge", "Notification received from: ${sbn.packageName}")
        
        // We need to find the messenger to send to Flutter.
        // Since the service might run when MainActivity is not in focus, 
        // we'll rely on the singleton approach or a simple broadcast if needed.
        // For simplicity during this sprint, we'll use a static channel in MainActivity
        // or a dedicated event bus.
        MainActivity.triggerNotificationPulse()
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
}
