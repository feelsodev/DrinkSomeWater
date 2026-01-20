package com.onceagain.drinksomewater.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.onceagain.drinksomewater.BuildConfig
import com.onceagain.drinksomewater.core.domain.model.NotificationSettings
import com.onceagain.drinksomewater.core.domain.model.UserProfile
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SettingsUiState(
    val goalMl: Int = UserProfile.MIN_GOAL_ML,
    val quickButtons: List<Int> = listOf(100, 200, 300, 500),
    val weightKg: Float = UserProfile.DEFAULT_WEIGHT_KG,
    val useHealthConnect: Boolean = false,
    val notificationEnabled: Boolean = false,
    val notificationInterval: Int = NotificationSettings.DEFAULT_INTERVAL_MINUTES,
    val notificationStartHour: Int = NotificationSettings.DEFAULT_START_HOUR,
    val notificationEndHour: Int = NotificationSettings.DEFAULT_END_HOUR,
    val appVersion: String = BuildConfig.VERSION_NAME,
    val isLoading: Boolean = true
) {
    val goalFormatted: String
        get() = "${goalMl}ml"

    val quickButtonsFormatted: String
        get() = quickButtons.joinToString(", ") + "ml"

    val recommendedIntakeMl: Int
        get() = (weightKg * UserProfile.ML_PER_KG).toInt()
}

sealed interface SettingsEvent {
    data object LoadSettings : SettingsEvent
    data class UpdateGoal(val goal: Int) : SettingsEvent
    data class UpdateQuickButtons(val buttons: List<Int>) : SettingsEvent
    data class UpdateQuickButton(val index: Int, val value: Int) : SettingsEvent
    data class UpdateWeight(val weightKg: Float) : SettingsEvent
    data object ToggleHealthConnect : SettingsEvent
    data object ToggleNotification : SettingsEvent
    data class UpdateNotificationInterval(val intervalMinutes: Int) : SettingsEvent
    data class UpdateNotificationTime(val startHour: Int, val endHour: Int) : SettingsEvent
}

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    private var currentUserProfile = UserProfile()
    private var currentNotificationSettings = NotificationSettings()

    init {
        loadSettings()
        observeSettings()
    }

    fun onEvent(event: SettingsEvent) {
        when (event) {
            SettingsEvent.LoadSettings -> loadSettings()
            is SettingsEvent.UpdateGoal -> updateGoal(event.goal)
            is SettingsEvent.UpdateQuickButtons -> updateQuickButtons(event.buttons)
            is SettingsEvent.UpdateQuickButton -> updateSingleQuickButton(event.index, event.value)
            is SettingsEvent.UpdateWeight -> updateWeight(event.weightKg)
            SettingsEvent.ToggleHealthConnect -> toggleHealthConnect()
            SettingsEvent.ToggleNotification -> toggleNotification()
            is SettingsEvent.UpdateNotificationInterval -> updateNotificationInterval(event.intervalMinutes)
            is SettingsEvent.UpdateNotificationTime -> updateNotificationTime(event.startHour, event.endHour)
        }
    }

    private fun loadSettings() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }

            val goal = settingsRepository.getGoal()
            val quickButtons = settingsRepository.getQuickButtons()
            val userProfile = settingsRepository.getUserProfile()
            val notificationSettings = settingsRepository.getNotificationSettings()

            currentUserProfile = userProfile
            currentNotificationSettings = notificationSettings

            _uiState.update {
                it.copy(
                    goalMl = goal,
                    quickButtons = quickButtons,
                    weightKg = userProfile.weightKg,
                    useHealthConnect = userProfile.useHealthConnect,
                    notificationEnabled = notificationSettings.enabled,
                    notificationInterval = notificationSettings.intervalMinutes,
                    notificationStartHour = notificationSettings.startHour,
                    notificationEndHour = notificationSettings.endHour,
                    isLoading = false
                )
            }
        }
    }

    private fun observeSettings() {
        viewModelScope.launch {
            settingsRepository.observeGoal().collect { goal ->
                _uiState.update { it.copy(goalMl = goal) }
            }
        }
        viewModelScope.launch {
            settingsRepository.observeQuickButtons().collect { buttons ->
                _uiState.update { it.copy(quickButtons = buttons) }
            }
        }
        viewModelScope.launch {
            settingsRepository.observeUserProfile().collect { profile ->
                currentUserProfile = profile
                _uiState.update {
                    it.copy(
                        weightKg = profile.weightKg,
                        useHealthConnect = profile.useHealthConnect
                    )
                }
            }
        }
        viewModelScope.launch {
            settingsRepository.observeNotificationSettings().collect { settings ->
                currentNotificationSettings = settings
                _uiState.update {
                    it.copy(
                        notificationEnabled = settings.enabled,
                        notificationInterval = settings.intervalMinutes,
                        notificationStartHour = settings.startHour,
                        notificationEndHour = settings.endHour
                    )
                }
            }
        }
    }

    private fun updateGoal(goal: Int) {
        viewModelScope.launch {
            val roundedGoal = (goal / 100) * 100
            val clampedGoal = roundedGoal.coerceIn(UserProfile.MIN_GOAL_ML, UserProfile.MAX_GOAL_ML)
            settingsRepository.setGoal(clampedGoal)
        }
    }

    private fun updateQuickButtons(buttons: List<Int>) {
        viewModelScope.launch {
            settingsRepository.setQuickButtons(buttons)
        }
    }

    private fun updateSingleQuickButton(index: Int, value: Int) {
        viewModelScope.launch {
            val currentButtons = _uiState.value.quickButtons.toMutableList()
            if (index in currentButtons.indices) {
                currentButtons[index] = value
                settingsRepository.setQuickButtons(currentButtons)
            }
        }
    }

    private fun updateWeight(weightKg: Float) {
        viewModelScope.launch {
            val updatedProfile = currentUserProfile.copy(weightKg = weightKg)
            settingsRepository.setUserProfile(updatedProfile)
        }
    }

    private fun toggleHealthConnect() {
        viewModelScope.launch {
            val updatedProfile = currentUserProfile.copy(
                useHealthConnect = !currentUserProfile.useHealthConnect
            )
            settingsRepository.setUserProfile(updatedProfile)
        }
    }

    private fun toggleNotification() {
        viewModelScope.launch {
            val updatedSettings = currentNotificationSettings.copy(
                enabled = !currentNotificationSettings.enabled
            )
            settingsRepository.setNotificationSettings(updatedSettings)
        }
    }

    private fun updateNotificationInterval(intervalMinutes: Int) {
        viewModelScope.launch {
            val updatedSettings = currentNotificationSettings.copy(
                intervalMinutes = intervalMinutes
            )
            settingsRepository.setNotificationSettings(updatedSettings)
        }
    }

    private fun updateNotificationTime(startHour: Int, endHour: Int) {
        viewModelScope.launch {
            val updatedSettings = currentNotificationSettings.copy(
                startHour = startHour,
                endHour = endHour
            )
            settingsRepository.setNotificationSettings(updatedSettings)
        }
    }
}
