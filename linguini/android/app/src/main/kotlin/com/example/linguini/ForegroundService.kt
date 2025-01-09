package com.example.linguini

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

class ForegroundService : Service() {
    private val CHANNEL_ID = "startForegroundService"

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("ForegroundService", "onStartCommand called")
        
        createNotificationChannel()

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Audio Streaming Active")
            .setContentText("The app is streaming audio in the background.")
            .setSmallIcon(R.drawable.ic_notification) // Replace with your app's icon
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        Log.d("ForegroundService", "Notification created")

        // Start the service in the foreground with the notification
        startForeground(1, notification)
        Log.d("ForegroundService", "Service started in the foreground")

        return START_STICKY
    }

    override fun onBind(intent: Intent?) = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d("ForegroundService", "Creating notification channel")
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            if (manager != null) {
                manager.createNotificationChannel(channel)
                Log.d("ForegroundService", "Notification channel created")
            } else {
                Log.e("ForegroundService", "NotificationManager is null, cannot create channel")
            }
        } else {
            Log.d("ForegroundService", "Notification channel not required (below Android O)")
        }
    }
}
