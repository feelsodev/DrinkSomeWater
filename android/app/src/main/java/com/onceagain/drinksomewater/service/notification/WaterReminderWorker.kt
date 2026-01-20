package com.onceagain.drinksomewater.service.notification

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject
import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import java.util.concurrent.TimeUnit

@HiltWorker
class WaterReminderWorker @AssistedInject constructor(
    @Assisted private val context: Context,
    @Assisted workerParams: WorkerParameters,
    private val notificationHelper: NotificationHelper,
    private val settingsRepository: SettingsRepository
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result {
        val settings = settingsRepository.getNotificationSettings()

        if (!settings.enabled) {
            return Result.success()
        }

        val currentHour = Clock.System.now()
            .toLocalDateTime(TimeZone.currentSystemDefault())
            .hour

        if (currentHour in settings.startHour until settings.endHour) {
            notificationHelper.showNotification()
        }

        return Result.success()
    }

    companion object {
        private const val WORK_NAME = "water_reminder_work"

        fun schedule(context: Context, intervalMinutes: Int) {
            val workRequest = PeriodicWorkRequestBuilder<WaterReminderWorker>(
                intervalMinutes.toLong(),
                TimeUnit.MINUTES
            ).build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.UPDATE,
                workRequest
            )
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
        }
    }
}
