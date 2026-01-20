package com.onceagain.drinksomewater.core.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class NotificationSettings(
    val enabled: Boolean = false,
    val intervalMinutes: Int = DEFAULT_INTERVAL_MINUTES,
    val startHour: Int = DEFAULT_START_HOUR,
    val endHour: Int = DEFAULT_END_HOUR
) {
    companion object {
        const val DEFAULT_INTERVAL_MINUTES = 60
        const val DEFAULT_START_HOUR = 9
        const val DEFAULT_END_HOUR = 21
    }
}
