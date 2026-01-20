package com.onceagain.drinksomewater.service.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class BootReceiver : BroadcastReceiver() {

    @Inject
    lateinit var settingsRepository: SettingsRepository

    @Inject
    lateinit var notificationHelper: NotificationHelper

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val pendingResult = goAsync()

        CoroutineScope(Dispatchers.IO).launch {
            try {
                rescheduleNotifications(context)
            } finally {
                pendingResult.finish()
            }
        }
    }

    private suspend fun rescheduleNotifications(context: Context) {
        val settings = settingsRepository.getNotificationSettings()
        
        if (!settings.enabled) return
        if (!notificationHelper.hasNotificationPermission()) return

        notificationHelper.createNotificationChannel()
        WaterReminderWorker.schedule(context, settings.intervalMinutes)
    }
}
