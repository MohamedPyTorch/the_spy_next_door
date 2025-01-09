package com.example.linguini

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.linguini/foregroundService"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startForegroundService") {
                // Start the service here
                val intent = Intent(this, ForegroundService::class.java)
                startService(intent)
                result.success("Service started")
            } else {
                result.notImplemented()
            }
        }
    }
}

