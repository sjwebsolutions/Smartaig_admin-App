package com.smartaig.admins.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager?

            val callbackChannel = NotificationChannel(
                "callback_notification_channel",
                "Callback & Alert Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            callbackChannel.description = "Channel for callback requests and urgent admin alerts"
            callbackChannel.enableVibration(true)
            callbackChannel.enableLights(true)
            callbackChannel.setShowBadge(true)
            notificationManager?.createNotificationChannel(callbackChannel)
        }
    }
}
