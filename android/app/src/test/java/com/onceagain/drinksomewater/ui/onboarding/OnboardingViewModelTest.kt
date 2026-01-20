package com.onceagain.drinksomewater.ui.onboarding

import app.cash.turbine.test
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.just
import io.mockk.mockk
import io.mockk.Runs
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class OnboardingViewModelTest {

    private val settingsRepository: SettingsRepository = mockk()
    private lateinit var viewModel: OnboardingViewModel

    private val testDispatcher = StandardTestDispatcher()

    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        coEvery { settingsRepository.getGoal() } returns 2000
        coEvery { settingsRepository.setGoal(any()) } just Runs
        coEvery { settingsRepository.isOnboardingCompleted() } returns false
        coEvery { settingsRepository.setOnboardingCompleted(any()) } just Runs
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun createViewModel(): OnboardingViewModel {
        return OnboardingViewModel(settingsRepository)
    }

    @Nested
    @DisplayName("초기화")
    inner class InitializationTest {
        @Test
        fun `초기 페이지는 0이다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(0, viewModel.uiState.value.currentPage)
        }

        @Test
        fun `총 페이지 수는 5개이다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(5, viewModel.uiState.value.totalPages)
        }

        @Test
        fun `초기 목표량은 2000ml이다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(2000, viewModel.uiState.value.goalMl)
        }
    }

    @Nested
    @DisplayName("페이지 네비게이션")
    inner class PageNavigationTest {
        @Test
        fun `다음 페이지로 이동`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.NextPage)
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(1, viewModel.uiState.value.currentPage)
        }

        @Test
        fun `이전 페이지로 이동`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.NextPage)
            testDispatcher.scheduler.advanceUntilIdle()
            viewModel.onEvent(OnboardingEvent.PreviousPage)
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(0, viewModel.uiState.value.currentPage)
        }

        @Test
        fun `첫 페이지에서 이전 이동 시 0에 머문다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.PreviousPage)
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(0, viewModel.uiState.value.currentPage)
        }

        @Test
        fun `마지막 페이지에서 다음 이동 시 마지막에 머문다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            repeat(10) {
                viewModel.onEvent(OnboardingEvent.NextPage)
                testDispatcher.scheduler.advanceUntilIdle()
            }

            assertEquals(4, viewModel.uiState.value.currentPage)
        }

        @Test
        fun `특정 페이지로 이동`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.GoToPage(3))
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(3, viewModel.uiState.value.currentPage)
        }
    }

    @Nested
    @DisplayName("목표 설정")
    inner class GoalSettingTest {
        @Test
        fun `목표량 변경`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.UpdateGoal(2500))
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(2500, viewModel.uiState.value.goalMl)
        }

        @Test
        fun `목표량은 최소값 미만으로 설정되지 않는다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.UpdateGoal(500))
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(1000, viewModel.uiState.value.goalMl)
        }

        @Test
        fun `목표량은 최대값 초과로 설정되지 않는다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.UpdateGoal(5000))
            testDispatcher.scheduler.advanceUntilIdle()

            assertEquals(4500, viewModel.uiState.value.goalMl)
        }
    }

    @Nested
    @DisplayName("온보딩 완료")
    inner class OnboardingCompletionTest {
        @Test
        fun `온보딩 완료 시 목표량이 저장된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.UpdateGoal(2500))
            testDispatcher.scheduler.advanceUntilIdle()
            viewModel.onEvent(OnboardingEvent.CompleteOnboarding)
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setGoal(2500) }
        }

        @Test
        fun `온보딩 완료 시 완료 플래그가 저장된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.CompleteOnboarding)
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setOnboardingCompleted(true) }
        }

        @Test
        fun `온보딩 완료 시 isCompleted 상태가 true가 된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val initial = awaitItem()
                assertFalse(initial.isCompleted)

                viewModel.onEvent(OnboardingEvent.CompleteOnboarding)
                testDispatcher.scheduler.advanceUntilIdle()

                val completed = awaitItem()
                assertTrue(completed.isCompleted)
            }
        }
    }

    @Nested
    @DisplayName("첫 페이지/마지막 페이지 플래그")
    inner class PageFlagsTest {
        @Test
        fun `첫 페이지에서 isFirstPage는 true`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            assertTrue(viewModel.uiState.value.isFirstPage)
        }

        @Test
        fun `마지막 페이지에서 isLastPage는 true`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.GoToPage(4))
            testDispatcher.scheduler.advanceUntilIdle()

            assertTrue(viewModel.uiState.value.isLastPage)
        }

        @Test
        fun `중간 페이지에서 isFirstPage와 isLastPage 모두 false`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(OnboardingEvent.GoToPage(2))
            testDispatcher.scheduler.advanceUntilIdle()

            assertFalse(viewModel.uiState.value.isFirstPage)
            assertFalse(viewModel.uiState.value.isLastPage)
        }
    }
}
