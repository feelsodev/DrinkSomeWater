package com.onceagain.drinksomewater.ui.history

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
import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import javax.inject.Inject

enum class HistoryViewMode {
    CALENDAR, LIST, TIMELINE
}

data class HistoryUiState(
    val records: List<WaterRecord> = emptyList(),
    val selectedRecord: WaterRecord? = null,
    val viewMode: HistoryViewMode = HistoryViewMode.CALENDAR,
    val isLoading: Boolean = true
) {
    val successDates: List<String>
        get() = records.filter { it.isSuccess }.map { it.date.toString() }

    val currentMonthSuccessCount: Int
        get() {
            val now = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()).date
            return records.count { record ->
                record.date.year == now.year && 
                record.date.month == now.month && 
                record.isSuccess
            }
        }

    val currentMonthTotalDays: Int
        get() {
            val now = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()).date
            return records.count { record ->
                record.date.year == now.year && record.date.month == now.month
            }
        }

    val groupedByMonth: Map<String, List<WaterRecord>>
        get() = records.groupBy { "${it.date.year}-${it.date.monthNumber.toString().padStart(2, '0')}" }
}

sealed interface HistoryEvent {
    data object Refresh : HistoryEvent
    data class SelectDate(val date: LocalDate) : HistoryEvent
    data class ChangeViewMode(val mode: HistoryViewMode) : HistoryEvent
}

@HiltViewModel
class HistoryViewModel @Inject constructor(
    private val waterRepository: WaterRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HistoryUiState())
    val uiState: StateFlow<HistoryUiState> = _uiState.asStateFlow()

    init {
        loadData()
        observeData()
    }

    fun onEvent(event: HistoryEvent) {
        when (event) {
            HistoryEvent.Refresh -> loadData()
            is HistoryEvent.SelectDate -> selectDate(event.date)
            is HistoryEvent.ChangeViewMode -> changeViewMode(event.mode)
        }
    }

    private fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }

            val records = waterRepository.getAllRecords()
                .sortedByDescending { it.date }

            _uiState.update {
                it.copy(
                    records = records,
                    isLoading = false
                )
            }
        }
    }

    private fun observeData() {
        viewModelScope.launch {
            waterRepository.observeAllRecords().collect { records ->
                _uiState.update {
                    it.copy(records = records.sortedByDescending { r -> r.date })
                }
            }
        }
    }

    private fun selectDate(date: LocalDate) {
        val record = _uiState.value.records.find { it.date == date }
        _uiState.update { it.copy(selectedRecord = record) }
    }

    private fun changeViewMode(mode: HistoryViewMode) {
        _uiState.update { it.copy(viewMode = mode) }
    }
}
