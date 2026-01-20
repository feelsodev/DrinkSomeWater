package com.onceagain.drinksomewater.core.data.datastore

import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.floatPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey

object PreferencesKeys {
    val GOAL = intPreferencesKey("goal")
    val QUICK_BUTTONS = stringPreferencesKey("quick_buttons")
    val WATER_RECORDS = stringPreferencesKey("water_records")

    val WEIGHT_KG = floatPreferencesKey("weight_kg")
    val USE_HEALTH_CONNECT = booleanPreferencesKey("use_health_connect")
    val ONBOARDING_COMPLETED = booleanPreferencesKey("onboarding_completed")

    val NOTIFICATION_ENABLED = booleanPreferencesKey("notification_enabled")
    val NOTIFICATION_INTERVAL = intPreferencesKey("notification_interval")
    val NOTIFICATION_START_HOUR = intPreferencesKey("notification_start_hour")
    val NOTIFICATION_END_HOUR = intPreferencesKey("notification_end_hour")

    val WIDGET_TODAY_WATER = intPreferencesKey("widget_today_water")
    val WIDGET_GOAL = intPreferencesKey("widget_goal")
    val WIDGET_LAST_UPDATED = stringPreferencesKey("widget_last_updated")
}
