import android.app.Service
import android.os.Build
import androidx.core.app.NotificationCompat
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class ForegroundService : Service() {

    private val CHANNEL_ID = "com.example.linguini.foregroundService"
    private val CHANNEL_NAME = "Foreground Service"
    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        // Initialize FlutterEngine
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.binaryMessenger // Necessary for the MethodChannel setup

        // Set up the MethodChannel for communication with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.linguini/foregroundService")
            .setMethodCallHandler { call, result ->
                if (call.method == "startForegroundService") {
                    startForegroundService()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun startForegroundService() {
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_DEFAULT)
            notificationManager.createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Audio Streaming")
            .setContentText("The audio streaming is running in the background.")
            .setSmallIcon(android.R.drawable.ic_notification_overlay)
            .build()

        startForeground(1, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        flutterEngine.destroy()  // Clean up and destroy the FlutterEngine

        // Using the updated API for stopForeground with STOP_FOREGROUND_REMOVE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(Service.STOP_FOREGROUND_REMOVE)
        } else {
            stopForeground(true)  // For older Android versions, this still works
        }
    }

    override fun onBind(intent: Intent?): android.os.IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }
}
