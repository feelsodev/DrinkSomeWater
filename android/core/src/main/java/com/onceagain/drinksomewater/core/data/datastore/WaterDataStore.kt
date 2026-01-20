package com.onceagain.drinksomewater.core.data.datastore

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.preferencesDataStore
import com.onceagain.drinksomewater.core.domain.model.NotificationSettings
import com.onceagain.drinksomewater.core.domain.model.UserProfile
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import com.onceagain.drinksomewater.core.domain.model.WaterRecordsWrapper
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "water_prefs")

@Singleton
class WaterDataStore @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val json = Json { ignoreUnknownKeys = true }

    private fun today(): LocalDate {
        return Clock.System.now()
            .toLocalDateTime(TimeZone.currentSystemDefault())
            .date
    }

    suspend fun getTodayRecord(): WaterRecord? {
        val records = getAllRecords()
        return records.find { it.date == today() }
    }

    suspend fun getRecord(date: LocalDate): WaterRecord? {
        val records = getAllRecords()
        return records.find { it.date == date }
    }

    suspend fun getAllRecords(): List<WaterRecord> {
        val prefs = context.dataStore.data.first()
        val jsonString = prefs[PreferencesKeys.WATER_RECORDS] ?: return emptyList()
        return try {
            json.decodeFromString<WaterRecordsWrapper>(jsonString).records
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun observeAllRecords(): Flow<List<WaterRecord>> {
        return context.dataStore.data.map { prefs ->
            val jsonString = prefs[PreferencesKeys.WATER_RECORDS] ?: return@map emptyList()
            try {
                json.decodeFromString<WaterRecordsWrapper>(jsonString).records
            } catch (e: Exception) {
                emptyList()
            }
        }
    }

    fun observeTodayRecord(): Flow<WaterRecord?> {
        return observeAllRecords().map { records ->
            records.find { it.date == today() }
        }
    }

    suspend fun saveRecord(record: WaterRecord) {
        val records = getAllRecords().toMutableList()
        val existingIndex = records.indexOfFirst { it.date == record.date }
        if (existingIndex >= 0) {
            records[existingIndex] = record
        } else {
            records.add(record)
        }
        saveAllRecords(records)
    }

    private suspend fun saveAllRecords(records: List<WaterRecord>) {
        val wrapper = WaterRecordsWrapper(records = records)
        val jsonString = json.encodeToString(wrapper)
        context.dataStore.edit { prefs ->
            prefs[PreferencesKeys.WATER_RECORDS] = jsonString
        }
    }

    suspend fun getGoal(): Int {
        val prefs = context.dataStore.data.first()
        return prefs[PreferencesKeys.GOAL] ?: WaterRecord.DEFAULT_GOAL
    }

    suspend fun setGoal(goal: Int) {
        context.dataStore.edit { prefs ->
            prefs[PreferencesKeys.GOAL] = goal
        }
    }

    fun observeGoal(): Flow<Int> {
        return context.dataStore.data.map { prefs ->
            prefs[PreferencesKeys.GOAL] ?: WaterRecord.DEFAULT_GOAL
        }
    }

    suspend fun getQuickButtons(): List<Int> {
        val prefs = context.dataStore.data.first()
        val jsonString = prefs[PreferencesKeys.QUICK_BUTTONS] ?: return DEFAULT_QUICK_BUTTONS
        return try {
            json.decodeFromString<List<Int>>(jsonString)
        } catch (e: Exception) {
            DEFAULT_QUICK_BUTTONS
        }
    }

    suspend fun setQuickButtons(buttons: List<Int>) {
        val jsonString = json.encodeToString(buttons)
        context.dataStore.edit { prefs ->
            prefs[PreferencesKeys.QUICK_BUTTONS] = jsonString
        }
    }

    fun observeQuickButtons(): Flow<List<Int>> {
        return context.dataStore.data.map { prefs ->
            val jsonString = prefs[PreferencesKeys.QUICK_BUTTONS] ?: return@map DEFAULT_QUICK_BUTTONS
            try {
                json.decodeFromString<List<Int>>(jsonString)
            } catch (e: Exception) {
                DEFAULT_QUICK_BUTTONS
            }
        }
    }

    suspend fun getUserProfile(): UserProfile {
        val prefs = context.dataStore.data.first()
        val weightKg = prefs[PreferencesKeys.WEIGHT_KG] ?: UserProfile.DEFAULT_WEIGHT_KG
        val useHealthConnect = prefs[PreferencesKeys.USE_HEALTH_CONNECT] ?: false
        val onboardingCompleted = prefs[PreferencesKeys.ONBOARDING_COMPLETED] ?: false
        return UserProfile(
            weightKg = weightKg,
            useHealthConnect = useHealthConnect,
            onboardingCompleted = onboardingCompleted
        )
    }

    suspend fun setUserProfile(profile: UserProfile) {
        context.dataStore.edit { prefs ->
            prefs[PreferencesKeys.WEIGHT_KG] = profile.weightKg
            prefs[PreferencesKeys.USE_HEALTH_CONNECT] = profile.useHealthConnect
            prefs[PreferencesKeys.ONBOARDING_COMPLETED] = profile.onboardingCompleted
        }
    }

    fun observeUserProfile(): Flow<UserProfile> {
        return context.dataStore.data.map { prefs ->
            val weightKg = prefs[PreferencesKeys.WEIGHT_KG] ?: UserProfile.DEFAULT_WEIGHT_KG
            val useHealthConnect = prefs[PreferencesKeys.USE_HEALTH_CONNECT] ?: false
            val onboardingCompleted = prefs[PreferencesKeys.ONBOARDING_COMPLETED] ?: false
            UserProfile(
                weightKg = weightKg,
                useHealthConnect = useHealthConnect,
                onboardingCompleted = onboardingCompleted
            )
        }
    }

    suspend fun getNotificationSettings(): NotificationSettings {
        val prefs = context.dataStore.data.first()
        return NotificationSettings(
            enabled = prefs[PreferencesKeys.NOTIFICATION_ENABLED] ?: false,
            intervalMinutes = prefs[PreferencesKeys.NOTIFICATION_INTERVAL]
                ?: NotificationSettings.DEFAULT_INTERVAL_MINUTES,
            startHour = prefs[PreferencesKeys.NOTIFICATION_START_HOUR]
                ?: NotificationSettings.DEFAULT_START_HOUR,
            endHour = prefs[PreferencesKeys.NOTIFICATION_END_HOUR]
                ?: NotificationSettings.DEFAULT_END_HOUR
        )
    }

    suspend fun setNotificationSettings(settings: NotificationSettings) {
        context.dataStore.edit { prefs ->
            prefs[PreferencesKeys.NOTIFICATION_ENABLED] = settings.enabled
            prefs[PreferencesKeys.NOTIFICATION_INTERVAL] = settings.intervalMinutes
            prefs[PreferencesKeys.NOTIFICATION_START_HOUR] = settings.startHour
            prefs[PreferencesKeys.NOTIFICATION_END_HOUR] = settings.endHour
        }
    }

    fun observeNotificationSettings(): Flow<NotificationSettings> {
        return context.dataStore.data.map { prefs ->
            NotificationSettings(
                enabled = prefs[PreferencesKeys.NOTIFICATION_ENABLED] ?: false,
                intervalMinutes = prefs[PreferencesKeys.NOTIFICATION_INTERVAL]
                    ?: NotificationSettings.DEFAULT_INTERVAL_MINUTES,
                startHour = prefs[PreferencesKeys.NOTIFICATION_START_HOUR]
                    ?: NotificationSettings.DEFAULT_START_HOUR,
                endHour = prefs[PreferencesKeys.NOTIFICATION_END_HOUR]
                    ?: NotificationSettings.DEFAULT_END_HOUR
            )
        }
    }

    suspend fun isOnboardingCompleted(): Boolean {
        val prefs = context.dataStore.data.first()
        return prefs[PreferencesKeys.ONBOARDING_COMPLETED] ?: false
    }

    suspend fun setOnboardingCompleted(completed: Boolean) {
        context.dataStore.edit { prefs ->
            prefs[PreferencesKeys.ONBOARDING_COMPLETED] = completed
        }
    }

    companion object {
        val DEFAULT_QUICK_BUTTONS = listOf(100, 200, 300, 500)
    }
}
