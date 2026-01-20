package com.onceagain.drinksomewater.ui.onboarding

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class OnboardingViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(OnboardingUiState())
    val uiState: StateFlow<OnboardingUiState> = _uiState.asStateFlow()

    init {
        loadInitialState()
    }

    private fun loadInitialState() {
        viewModelScope.launch {
            val goal = settingsRepository.getGoal()
            _uiState.update { it.copy(goalMl = goal) }
        }
    }

    fun onEvent(event: OnboardingEvent) {
        when (event) {
            is OnboardingEvent.NextPage -> nextPage()
            is OnboardingEvent.PreviousPage -> previousPage()
            is OnboardingEvent.GoToPage -> goToPage(event.page)
            is OnboardingEvent.UpdateGoal -> updateGoal(event.goalMl)
            is OnboardingEvent.CompleteOnboarding -> completeOnboarding()
        }
    }

    private fun nextPage() {
        _uiState.update { state ->
            val nextPage = (state.currentPage + 1).coerceAtMost(state.totalPages - 1)
            state.copy(currentPage = nextPage)
        }
    }

    private fun previousPage() {
        _uiState.update { state ->
            val prevPage = (state.currentPage - 1).coerceAtLeast(0)
            state.copy(currentPage = prevPage)
        }
    }

    private fun goToPage(page: Int) {
        _uiState.update { state ->
            val validPage = page.coerceIn(0, state.totalPages - 1)
            state.copy(currentPage = validPage)
        }
    }

    private fun updateGoal(goalMl: Int) {
        val clampedGoal = goalMl.coerceIn(MIN_GOAL, MAX_GOAL)
        _uiState.update { it.copy(goalMl = clampedGoal) }
    }

    private fun completeOnboarding() {
        viewModelScope.launch {
            val currentGoal = _uiState.value.goalMl
            settingsRepository.setGoal(currentGoal)
            settingsRepository.setOnboardingCompleted(true)
            _uiState.update { it.copy(isCompleted = true) }
        }
    }

    companion object {
        const val MIN_GOAL = 1000
        const val MAX_GOAL = 4500
    }
}
