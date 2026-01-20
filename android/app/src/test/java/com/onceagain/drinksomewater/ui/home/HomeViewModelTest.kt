package com.onceagain.drinksomewater.ui.home

import app.cash.turbine.test
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.just
import io.mockk.mockk
import io.mockk.Runs
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
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class HomeViewModelTest {

    private val waterRepository: WaterRepository = mockk()
    private lateinit var viewModel: HomeViewModel
    
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
    ): HomeViewModel {
        coEvery { waterRepository.getTodayRecord() } returns initialRecord
        coEvery { waterRepository.getGoal() } returns goal
        coEvery { waterRepository.observeTodayRecord() } returns flowOf(initialRecord)
        coEvery { waterRepository.addWater(any()) } just Runs
        coEvery { waterRepository.subtractWater(any()) } just Runs
        coEvery { waterRepository.resetToday() } just Runs
        
        return HomeViewModel(waterRepository)
    }

    @Nested
    @DisplayName("초기화")
    inner class InitializationTest {
        @Test
        fun `초기 상태는 로딩 후 데이터가 로드된다`() = runTest {
            viewModel = createViewModel(
                initialRecord = createRecord(value = 500, goal = 2000)
            )
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(500, state.currentMl)
                assertEquals(2000, state.goalMl)
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
                assertEquals(listOf(100, 200, 300, 500), state.quickButtons)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("AddWater 이벤트")
    inner class AddWaterTest {
        @Test
        fun `AddWater 시 Repository addWater가 호출된다`() = runTest {
            viewModel = createViewModel(initialRecord = createRecord(value = 0))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(HomeEvent.AddWater(100))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { waterRepository.addWater(100) }
        }
    }

    @Nested
    @DisplayName("SubtractWater 이벤트")
    inner class SubtractWaterTest {
        @Test
        fun `SubtractWater 시 Repository subtractWater가 호출된다`() = runTest {
            viewModel = createViewModel(initialRecord = createRecord(value = 500))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(HomeEvent.SubtractWater(200))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { waterRepository.subtractWater(200) }
        }
    }

    @Nested
    @DisplayName("ResetToday 이벤트")
    inner class ResetTodayTest {
        @Test
        fun `ResetToday 시 Repository resetToday가 호출된다`() = runTest {
            viewModel = createViewModel(initialRecord = createRecord(value = 1500))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(HomeEvent.ResetToday)
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { waterRepository.resetToday() }
        }
    }

    @Nested
    @DisplayName("ToggleSubtractMode 이벤트")
    inner class ToggleSubtractModeTest {
        @Test
        fun `ToggleSubtractMode 시 모드가 전환된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val initial = awaitItem()
                assertFalse(initial.isSubtractMode)

                viewModel.onEvent(HomeEvent.ToggleSubtractMode)
                assertTrue(awaitItem().isSubtractMode)

                viewModel.onEvent(HomeEvent.ToggleSubtractMode)
                assertFalse(awaitItem().isSubtractMode)

                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("계산 프로퍼티")
    inner class ComputedPropertiesTest {
        @Test
        fun `progress 계산이 정확하다`() = runTest {
            viewModel = createViewModel(
                initialRecord = createRecord(value = 1500, goal = 2000)
            )
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(0.75f, state.progress, 0.001f)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `remainingMl 계산이 정확하다`() = runTest {
            viewModel = createViewModel(
                initialRecord = createRecord(value = 1500, goal = 2000)
            )
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(500, state.remainingMl)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `remainingCups 계산이 정확하다`() = runTest {
            viewModel = createViewModel(
                initialRecord = createRecord(value = 1500, goal = 2000)
            )
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(2, state.remainingCups) // 500ml / 250ml = 2잔
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `isGoalAchieved 계산이 정확하다`() = runTest {
            viewModel = createViewModel(
                initialRecord = createRecord(value = 2000, goal = 2000, isSuccess = true)
            )
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertTrue(state.isGoalAchieved)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `progressPercent 계산이 정확하다`() = runTest {
            viewModel = createViewModel(
                initialRecord = createRecord(value = 1500, goal = 2000)
            )
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(75, state.progressPercent)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("NotificationBanner")
    inner class NotificationBannerTest {
        @Test
        fun `DismissNotificationBanner 시 배너가 숨겨진다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(HomeEvent.DismissNotificationBanner)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertFalse(state.showNotificationBanner)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }
}
