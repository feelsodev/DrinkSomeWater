package com.onceagain.drinksomewater.core.domain.repository

import com.onceagain.drinksomewater.core.domain.model.NotificationSettings
import com.onceagain.drinksomewater.core.domain.model.UserProfile
import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    suspend fun getGoal(): Int
    suspend fun setGoal(goal: Int)
    fun observeGoal(): Flow<Int>

    suspend fun getQuickButtons(): List<Int>
    suspend fun setQuickButtons(buttons: List<Int>)
    fun observeQuickButtons(): Flow<List<Int>>

    suspend fun getUserProfile(): UserProfile
    suspend fun setUserProfile(profile: UserProfile)
    fun observeUserProfile(): Flow<UserProfile>

    suspend fun getNotificationSettings(): NotificationSettings
    suspend fun setNotificationSettings(settings: NotificationSettings)
    fun observeNotificationSettings(): Flow<NotificationSettings>

    suspend fun isOnboardingCompleted(): Boolean
    suspend fun setOnboardingCompleted(completed: Boolean)
}
