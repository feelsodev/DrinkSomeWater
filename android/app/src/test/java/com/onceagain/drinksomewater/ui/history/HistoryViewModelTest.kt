package com.onceagain.drinksomewater.ui.history

import app.cash.turbine.test
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlinx.datetime.LocalDate
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class HistoryViewModelTest {

    private val waterRepository: WaterRepository = mockk()
    private lateinit var viewModel: HistoryViewModel

    private val testDispatcher = StandardTestDispatcher()

    private fun createRecord(
        date: LocalDate,
        value: Int = 0,
        goal: Int = 2000,
        isSuccess: Boolean = value >= goal
    ) = WaterRecord(
        date = date,
        value = value,
        isSuccess = isSuccess,
        goal = goal
    )

    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun createViewModel(records: List<WaterRecord> = emptyList()): HistoryViewModel {
        coEvery { waterRepository.getAllRecords() } returns records
        coEvery { waterRepository.observeAllRecords() } returns flowOf(records)
        return HistoryViewModel(waterRepository)
    }

    @Nested
    @DisplayName("데이터 로드")
    inner class DataLoadTest {
        @Test
        fun `ViewDidLoad 시 전체 기록이 로드된다`() = runTest {
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 20), value = 2000, isSuccess = true),
                createRecord(date = LocalDate(2026, 1, 19), value = 1500),
                createRecord(date = LocalDate(2026, 1, 18), value = 2500, isSuccess = true)
            )
            viewModel = createViewModel(records)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(3, state.records.size)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `successDates가 올바르게 필터링된다`() = runTest {
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 20), value = 2000, isSuccess = true),
                createRecord(date = LocalDate(2026, 1, 19), value = 1500, isSuccess = false),
                createRecord(date = LocalDate(2026, 1, 18), value = 2500, isSuccess = true)
            )
            viewModel = createViewModel(records)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(2, state.successDates.size)
                assertTrue(state.successDates.contains("2026-01-20"))
                assertTrue(state.successDates.contains("2026-01-18"))
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("날짜 선택")
    inner class SelectDateTest {
        @Test
        fun `SelectDate 시 해당 날짜 기록이 선택된다`() = runTest {
            val targetDate = LocalDate(2026, 1, 19)
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 20), value = 2000),
                createRecord(date = targetDate, value = 1500),
                createRecord(date = LocalDate(2026, 1, 18), value = 2500)
            )
            viewModel = createViewModel(records)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(HistoryEvent.SelectDate(targetDate))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(targetDate, state.selectedRecord?.date)
                assertEquals(1500, state.selectedRecord?.value)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `존재하지 않는 날짜 선택 시 selectedRecord는 null이 된다`() = runTest {
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 20), value = 2000)
            )
            viewModel = createViewModel(records)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(HistoryEvent.SelectDate(LocalDate(2026, 1, 15)))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertNull(state.selectedRecord)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("뷰 모드 변경")
    inner class ViewModeTest {
        @Test
        fun `ChangeViewMode 시 뷰 모드가 변경된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val initial = awaitItem()
                assertEquals(HistoryViewMode.CALENDAR, initial.viewMode)

                viewModel.onEvent(HistoryEvent.ChangeViewMode(HistoryViewMode.LIST))
                assertEquals(HistoryViewMode.LIST, awaitItem().viewMode)

                viewModel.onEvent(HistoryEvent.ChangeViewMode(HistoryViewMode.TIMELINE))
                assertEquals(HistoryViewMode.TIMELINE, awaitItem().viewMode)

                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("월간 통계")
    inner class MonthlyStatsTest {
        @Test
        fun `monthlySuccessCount 계산이 정확하다`() = runTest {
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 20), value = 2000, isSuccess = true),
                createRecord(date = LocalDate(2026, 1, 19), value = 1500, isSuccess = false),
                createRecord(date = LocalDate(2026, 1, 18), value = 2500, isSuccess = true),
                createRecord(date = LocalDate(2025, 12, 31), value = 2000, isSuccess = true)
            )
            viewModel = createViewModel(records)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(2, state.currentMonthSuccessCount)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `monthlyTotalDays 계산이 정확하다`() = runTest {
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 20), value = 2000),
                createRecord(date = LocalDate(2026, 1, 19), value = 1500),
                createRecord(date = LocalDate(2026, 1, 18), value = 2500),
                createRecord(date = LocalDate(2025, 12, 31), value = 2000)
            )
            viewModel = createViewModel(records)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(3, state.currentMonthTotalDays)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("정렬")
    inner class SortingTest {
        @Test
        fun `기록은 날짜 역순으로 정렬된다`() = runTest {
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 18), value = 1000),
                createRecord(date = LocalDate(2026, 1, 20), value = 2000),
                createRecord(date = LocalDate(2026, 1, 19), value = 1500)
            )
            viewModel = createViewModel(records)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(LocalDate(2026, 1, 20), state.records[0].date)
                assertEquals(LocalDate(2026, 1, 19), state.records[1].date)
                assertEquals(LocalDate(2026, 1, 18), state.records[2].date)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }
}
