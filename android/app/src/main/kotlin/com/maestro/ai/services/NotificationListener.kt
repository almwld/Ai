package com.maestro.ai.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class NotificationListener : NotificationListenerService() {
    
    companion object {
        private const val TAG = "MaestroNotification"
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Notification Listener created")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Notification Listener destroyed")
    }
    
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let {
            val packageName = it.packageName
            val notificationTitle = it.notification.extras.getString("android.title") ?: ""
            val notificationText = it.notification.extras.getCharSequence("android.text")?.toString() ?: ""
            
            Log.d(TAG, "Notification from $packageName: $notificationTitle - $notificationText")
            
            // TODO: Process notification for voice commands
            // Example: "Read last notification" command
        }
    }
    
    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        sbn?.let {
            Log.d(TAG, "Notification removed from ${it.packageName}")
        }
    }
    
    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Notification Listener connected")
    }
    
    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d(TAG, "Notification Listener disconnected")
    }
    
    // Get all active notifications
    fun getActiveNotificationsList(): List<Map<String, String>> {
        return try {
            activeNotifications.map { sbn ->
                mapOf(
                    "packageName" to sbn.packageName,
                    "title" to (sbn.notification.extras.getString("android.title") ?: ""),
                    "text" to (sbn.notification.extras.getCharSequence("android.text")?.toString() ?: ""),
                    "time" to sbn.postTime.toString()
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting notifications: ${e.message}")
            emptyList()
        }
    }
}
