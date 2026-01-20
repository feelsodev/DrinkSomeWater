package com.onceagain.drinksomewater.wear.ui

import app.cash.turbine.test
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import com.onceagain.drinksomewater.wear.data.DataLayerService
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.Runs
import io.mockk.verify
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
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class WatchViewModelTest {

    private val waterRepository: WaterRepository = mockk()
    private val dataLayerService: DataLayerService = mockk(relaxed = true)
    private lateinit var viewModel: WatchViewModel

    private val testDispatcher = StandardTestDispatcher()
    private val today = LocalDate(2026, 1, 20)

    private fun createRecord(
        value: Int = 0,
        goal: Int = 2000,
        isSuccess: Boolean = value >= goal
    ) = WaterRecord(
        date = today,
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

    private fun createViewModel(
        initialRecord: WaterRecord = createRecord(),
        goal: Int = 2000
    ): WatchViewModel {
        coEvery { waterRepository.getTodayRecord() } returns initialRecord
        coEvery { waterRepository.getGoal() } returns goal
        coEvery { waterRepository.observeTodayRecord() } returns flowOf(initialRecord)
        coEvery { waterRepository.addWater(any()) } just Runs
        every { dataLayerService.sendAddWater(any()) } just Runs

        return WatchViewModel(waterRepository, dataLayerService)
    }

    @Nested
    @DisplayName("초기화")
    inner class InitializationTest {
        @Test
        fun `초기 상태는 로딩 후 데이터가 로드된다`() = runTest {
            viewModel = createViewModel(initialRecord = createRecord(value = 400, goal = 1800))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(400, state.currentMl)
                assertEquals(1800, state.goalMl)
                assertFalse(state.isLoading)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `초기 퀵버튼은 기본값으로 설정된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(listOf(150, 250, 300, 500), state.quickButtons)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("AddWater 이벤트")
    inner class AddWaterTest {
        @Test
        fun `AddWater 시 Repository addWater가 호출된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(WatchEvent.AddWater(150))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { waterRepository.addWater(150) }
            verify { dataLayerService.sendAddWater(150) }
        }
    }

    @Nested
    @DisplayName("CustomAmount 이벤트")
    inner class CustomAmountTest {
        @Test
        fun `UpdateCustomAmount 시 상태가 변경된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(WatchEvent.UpdateCustomAmount(350))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(350, state.customAmount)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `ConfirmCustomAmount 시 Repository addWater가 호출된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(WatchEvent.UpdateCustomAmount(300))
            viewModel.onEvent(WatchEvent.ConfirmCustomAmount)
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { waterRepository.addWater(300) }
            verify { dataLayerService.sendAddWater(300) }
        }
    }
}
