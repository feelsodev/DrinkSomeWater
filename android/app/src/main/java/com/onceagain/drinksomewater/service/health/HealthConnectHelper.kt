package com.onceagain.drinksomewater.service.health

import android.content.Context
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HydrationRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.liters
import dagger.hilt.android.qualifiers.ApplicationContext
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.math.roundToInt

@Singleton
class HealthConnectHelper @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private var healthConnectClientProvider: () -> HealthConnectClient = {
        HealthConnectClient.getOrCreate(context)
    }
    private var sdkStatusProvider: (Context) -> Int = HealthConnectClient::getSdkStatus

    internal constructor(
        context: Context,
        healthConnectClient: HealthConnectClient,
        sdkStatusProvider: (Context) -> Int
    ) : this(context) {
        this.healthConnectClientProvider = { healthConnectClient }
        this.sdkStatusProvider = sdkStatusProvider
    }

    private val permissions = setOf(
        HealthPermission.getReadPermission(WeightRecord::class),
        HealthPermission.getWritePermission(HydrationRecord::class)
    )

    fun checkAvailability(): Boolean {
        return try {
            sdkStatusProvider(context) == HealthConnectClient.SDK_AVAILABLE
        } catch (exception: Exception) {
            false
        }
    }

    suspend fun requestPermissions(permissionLauncher: ActivityResultLauncher<Set<String>>): Boolean {
        if (!checkAvailability()) {
            return false
        }

        return try {
            val healthConnectClient = healthConnectClientProvider()
            val granted = healthConnectClient.permissionController.getGrantedPermissions()
            if (granted.containsAll(permissions)) {
                true
            } else {
                permissionLauncher.launch(permissions)
                false
            }
        } catch (exception: Exception) {
            false
        }
    }

    suspend fun getLatestWeight(): Float? {
        if (!checkAvailability()) {
            return null
        }

        return try {
            val healthConnectClient = healthConnectClientProvider()
            val granted = healthConnectClient.permissionController.getGrantedPermissions()
            val readPermission = HealthPermission.getReadPermission(WeightRecord::class)
            if (!granted.contains(readPermission)) {
                return null
            }

            val response = healthConnectClient.readRecords(
                ReadRecordsRequest(
                    recordType = WeightRecord::class,
                    timeRangeFilter = TimeRangeFilter.after(Instant.EPOCH),
                    ascendingOrder = false,
                    pageSize = 1
                )
            )

            response.records.firstOrNull()?.weight?.inKilograms?.toFloat()
        } catch (exception: Exception) {
            null
        }
    }

    fun calculateRecommendedIntake(weightKg: Float): Int {
        return (weightKg * 33f).roundToInt()
    }

    suspend fun writeHydrationRecord(amountMl: Int, timestamp: Instant): Boolean {
        if (!checkAvailability()) {
            return false
        }

        return try {
            val healthConnectClient = healthConnectClientProvider()
            val granted = healthConnectClient.permissionController.getGrantedPermissions()
            val writePermission = HealthPermission.getWritePermission(HydrationRecord::class)
            if (!granted.contains(writePermission)) {
                return false
            }

            val record = HydrationRecord(
                startTime = timestamp,
                startZoneOffset = null,
                endTime = timestamp.plusSeconds(1),
                endZoneOffset = null,
                volume = (amountMl.toDouble() / 1000.0).liters
            )

            healthConnectClient.insertRecords(listOf(record))
            true
        } catch (exception: Exception) {
            false
        }
    }
}
