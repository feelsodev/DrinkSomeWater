package com.onceagain.drinksomewater.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeUiState(
    val currentMl: Int = 0,
    val goalMl: Int = WaterRecord.DEFAULT_GOAL,
    val quickButtons: List<Int> = listOf(100, 200, 300, 500),
    val isSubtractMode: Boolean = false,
    val isLoading: Boolean = true,
    val showNotificationBanner: Boolean = false
) {
    val progress: Float
        get() = if (goalMl == 0) 0f else minOf(1f, currentMl.toFloat() / goalMl)

    val progressPercent: Int
        get() = (progress * 100).toInt()

    val remainingMl: Int
        get() = maxOf(0, goalMl - currentMl)

    val remainingCups: Int
        get() = remainingMl / WaterRecord.CUP_SIZE_ML

    val isGoalAchieved: Boolean
        get() = currentMl >= goalMl
}

sealed interface HomeEvent {
    data object Refresh : HomeEvent
    data class AddWater(val amount: Int) : HomeEvent
    data class SubtractWater(val amount: Int) : HomeEvent
    data object ResetToday : HomeEvent
    data object ToggleSubtractMode : HomeEvent
    data object DismissNotificationBanner : HomeEvent
}

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val waterRepository: WaterRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadData()
        observeData()
    }

    fun onEvent(event: HomeEvent) {
        when (event) {
            HomeEvent.Refresh -> loadData()
            is HomeEvent.AddWater -> addWater(event.amount)
            is HomeEvent.SubtractWater -> subtractWater(event.amount)
            HomeEvent.ResetToday -> resetToday()
            HomeEvent.ToggleSubtractMode -> toggleSubtractMode()
            HomeEvent.DismissNotificationBanner -> dismissNotificationBanner()
        }
    }

    private fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }

            val record = waterRepository.getTodayRecord()
            val goal = waterRepository.getGoal()

            _uiState.update {
                it.copy(
                    currentMl = record?.value ?: 0,
                    goalMl = goal,
                    isLoading = false
                )
            }
        }
    }

    private fun observeData() {
        viewModelScope.launch {
            waterRepository.observeTodayRecord().collect { record ->
                record?.let {
                    _uiState.update { state ->
                        state.copy(
                            currentMl = it.value,
                            goalMl = it.goal
                        )
                    }
                }
            }
        }
    }

    private fun addWater(amount: Int) {
        viewModelScope.launch {
            waterRepository.addWater(amount)
        }
    }

    private fun subtractWater(amount: Int) {
        viewModelScope.launch {
            waterRepository.subtractWater(amount)
        }
    }

    private fun resetToday() {
        viewModelScope.launch {
            waterRepository.resetToday()
        }
    }

    private fun toggleSubtractMode() {
        _uiState.update { it.copy(isSubtractMode = !it.isSubtractMode) }
    }

    private fun dismissNotificationBanner() {
        _uiState.update { it.copy(showNotificationBanner = false) }
    }
}
