package com.onceagain.drinksomewater.core.data.repository

import com.onceagain.drinksomewater.core.data.datastore.WaterDataStore
import com.onceagain.drinksomewater.core.domain.model.NotificationSettings
import com.onceagain.drinksomewater.core.domain.model.UserProfile
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SettingsRepositoryImpl @Inject constructor(
    private val dataStore: WaterDataStore
) : SettingsRepository {

    override suspend fun getGoal(): Int = dataStore.getGoal()

    override suspend fun setGoal(goal: Int) = dataStore.setGoal(goal)

    override fun observeGoal(): Flow<Int> = dataStore.observeGoal()

    override suspend fun getQuickButtons(): List<Int> = dataStore.getQuickButtons()

    override suspend fun setQuickButtons(buttons: List<Int>) = dataStore.setQuickButtons(buttons)

    override fun observeQuickButtons(): Flow<List<Int>> = dataStore.observeQuickButtons()

    override suspend fun getUserProfile(): UserProfile = dataStore.getUserProfile()

    override suspend fun setUserProfile(profile: UserProfile) = dataStore.setUserProfile(profile)

    override fun observeUserProfile(): Flow<UserProfile> = dataStore.observeUserProfile()

    override suspend fun getNotificationSettings(): NotificationSettings = dataStore.getNotificationSettings()

    override suspend fun setNotificationSettings(settings: NotificationSettings) =
        dataStore.setNotificationSettings(settings)

    override fun observeNotificationSettings(): Flow<NotificationSettings> =
        dataStore.observeNotificationSettings()

    override suspend fun isOnboardingCompleted(): Boolean = dataStore.isOnboardingCompleted()

    override suspend fun setOnboardingCompleted(completed: Boolean) =
        dataStore.setOnboardingCompleted(completed)
}
