package com.onceagain.drinksomewater.wear.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import com.onceagain.drinksomewater.wear.data.DataLayerService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface WatchEvent {
    data object Refresh : WatchEvent
    data class AddWater(val amount: Int) : WatchEvent
    data class UpdateCustomAmount(val amount: Int) : WatchEvent
    data object ConfirmCustomAmount : WatchEvent
}

@HiltViewModel
class WatchViewModel @Inject constructor(
    private val waterRepository: WaterRepository,
    private val dataLayerService: DataLayerService
) : ViewModel() {

    private val _uiState = MutableStateFlow(WatchUiState())
    val uiState: StateFlow<WatchUiState> = _uiState.asStateFlow()

    init {
        loadData()
        observeData()
    }

    fun onEvent(event: WatchEvent) {
        when (event) {
            WatchEvent.Refresh -> loadData()
            is WatchEvent.AddWater -> addWater(event.amount)
            is WatchEvent.UpdateCustomAmount -> updateCustomAmount(event.amount)
            WatchEvent.ConfirmCustomAmount -> confirmCustomAmount()
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
            dataLayerService.sendAddWater(amount)
        }
    }

    private fun updateCustomAmount(amount: Int) {
        _uiState.update { it.copy(customAmount = amount) }
    }

    private fun confirmCustomAmount() {
        addWater(uiState.value.customAmount)
    }
}
