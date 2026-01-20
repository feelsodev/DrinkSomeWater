package com.onceagain.drinksomewater.widget.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

private val Context.widgetDataStore: DataStore<Preferences> by preferencesDataStore(name = "widget_prefs")

object WaterWidgetDataManager {
    
    private val json = Json { ignoreUnknownKeys = true }
    
    private val KEY_CURRENT_ML = intPreferencesKey("widget_current_ml")
    private val KEY_GOAL_ML = intPreferencesKey("widget_goal_ml")
    private val KEY_QUICK_BUTTONS = stringPreferencesKey("widget_quick_buttons")
    
    suspend fun getWidgetState(context: Context): WaterWidgetState {
        val prefs = context.widgetDataStore.data.first()
        val currentMl = prefs[KEY_CURRENT_ML] ?: 0
        val goalMl = prefs[KEY_GOAL_ML] ?: 2000
        val quickButtonsJson = prefs[KEY_QUICK_BUTTONS]
        val quickButtons = quickButtonsJson?.let {
            try { json.decodeFromString<List<Int>>(it) } catch (e: Exception) { null }
        } ?: listOf(150, 300, 500)
        
        return WaterWidgetState(
            currentMl = currentMl,
            goalMl = goalMl,
            quickButtons = quickButtons
        )
    }
    
    fun observeWidgetState(context: Context): Flow<WaterWidgetState> {
        return context.widgetDataStore.data.map { prefs ->
            val currentMl = prefs[KEY_CURRENT_ML] ?: 0
            val goalMl = prefs[KEY_GOAL_ML] ?: 2000
            val quickButtonsJson = prefs[KEY_QUICK_BUTTONS]
            val quickButtons = quickButtonsJson?.let {
                try { json.decodeFromString<List<Int>>(it) } catch (e: Exception) { null }
            } ?: listOf(150, 300, 500)
            
            WaterWidgetState(
                currentMl = currentMl,
                goalMl = goalMl,
                quickButtons = quickButtons
            )
        }
    }
    
    suspend fun updateWidgetState(context: Context, currentMl: Int, goalMl: Int) {
        context.widgetDataStore.edit { prefs ->
            prefs[KEY_CURRENT_ML] = currentMl
            prefs[KEY_GOAL_ML] = goalMl
        }
    }
    
    suspend fun updateQuickButtons(context: Context, quickButtons: List<Int>) {
        context.widgetDataStore.edit { prefs ->
            prefs[KEY_QUICK_BUTTONS] = json.encodeToString(quickButtons)
        }
    }
}
