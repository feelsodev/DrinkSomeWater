package com.onceagain.drinksomewater.ui.settings

import app.cash.turbine.test
import com.onceagain.drinksomewater.core.domain.model.NotificationSettings
import com.onceagain.drinksomewater.core.domain.model.UserProfile
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
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
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class SettingsViewModelTest {

    private val settingsRepository: SettingsRepository = mockk()
    private lateinit var viewModel: SettingsViewModel

    private val testDispatcher = StandardTestDispatcher()

    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun createViewModel(
        goal: Int = 2000,
        quickButtons: List<Int> = listOf(100, 200, 300, 500),
        userProfile: UserProfile = UserProfile(),
        notificationSettings: NotificationSettings = NotificationSettings()
    ): SettingsViewModel {
        coEvery { settingsRepository.getGoal() } returns goal
        coEvery { settingsRepository.getQuickButtons() } returns quickButtons
        coEvery { settingsRepository.getUserProfile() } returns userProfile
        coEvery { settingsRepository.getNotificationSettings() } returns notificationSettings
        coEvery { settingsRepository.observeGoal() } returns flowOf(goal)
        coEvery { settingsRepository.observeQuickButtons() } returns flowOf(quickButtons)
        coEvery { settingsRepository.observeUserProfile() } returns flowOf(userProfile)
        coEvery { settingsRepository.observeNotificationSettings() } returns flowOf(notificationSettings)
        coEvery { settingsRepository.setGoal(any()) } just Runs
        coEvery { settingsRepository.setQuickButtons(any()) } just Runs
        coEvery { settingsRepository.setUserProfile(any()) } just Runs
        coEvery { settingsRepository.setNotificationSettings(any()) } just Runs

        return SettingsViewModel(settingsRepository)
    }

    @Nested
    @DisplayName("초기화")
    inner class InitializationTest {
        @Test
        fun `초기 상태에서 설정값이 로드된다`() = runTest {
            viewModel = createViewModel(
                goal = 2500,
                quickButtons = listOf(150, 250, 350, 500),
                userProfile = UserProfile(weightKg = 70f)
            )
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals(2500, state.goalMl)
                assertEquals(listOf(150, 250, 350, 500), state.quickButtons)
                assertEquals(70f, state.weightKg)
                assertFalse(state.isLoading)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `앱 버전이 표시된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertTrue(state.appVersion.isNotEmpty())
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("목표량 설정")
    inner class GoalSettingTest {
        @Test
        fun `UpdateGoal 시 목표량이 100 단위로 반올림된다`() = runTest {
            viewModel = createViewModel(goal = 2000)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.UpdateGoal(2150))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setGoal(2100) }
        }

        @Test
        fun `UpdateGoal 시 최소값은 1000ml이다`() = runTest {
            viewModel = createViewModel(goal = 2000)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.UpdateGoal(500))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setGoal(1000) }
        }

        @Test
        fun `UpdateGoal 시 최대값은 4500ml이다`() = runTest {
            viewModel = createViewModel(goal = 2000)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.UpdateGoal(5000))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setGoal(4500) }
        }
    }

    @Nested
    @DisplayName("퀵버튼 설정")
    inner class QuickButtonsSettingTest {
        @Test
        fun `UpdateQuickButtons 시 퀵버튼이 저장된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            val newButtons = listOf(150, 300, 450, 600)
            viewModel.onEvent(SettingsEvent.UpdateQuickButtons(newButtons))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setQuickButtons(newButtons) }
        }

        @Test
        fun `UpdateQuickButton 시 특정 인덱스의 버튼이 업데이트된다`() = runTest {
            viewModel = createViewModel(quickButtons = listOf(100, 200, 300, 500))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.UpdateQuickButton(index = 1, value = 250))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setQuickButtons(listOf(100, 250, 300, 500)) }
        }
    }

    @Nested
    @DisplayName("프로필 설정")
    inner class ProfileSettingTest {
        @Test
        fun `UpdateWeight 시 체중이 저장된다`() = runTest {
            viewModel = createViewModel(userProfile = UserProfile(weightKg = 65f))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.UpdateWeight(70f))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setUserProfile(match { it.weightKg == 70f }) }
        }

        @Test
        fun `ToggleHealthConnect 시 Health Connect 설정이 토글된다`() = runTest {
            viewModel = createViewModel(userProfile = UserProfile(useHealthConnect = false))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.ToggleHealthConnect)
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setUserProfile(match { it.useHealthConnect }) }
        }

        @Test
        fun `체중 기반 권장량이 올바르게 계산된다`() = runTest {
            viewModel = createViewModel(userProfile = UserProfile(weightKg = 70f))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                // 70kg * 33ml = 2310ml
                assertEquals(2310, state.recommendedIntakeMl)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }

    @Nested
    @DisplayName("알림 설정")
    inner class NotificationSettingTest {
        @Test
        fun `ToggleNotification 시 알림 설정이 토글된다`() = runTest {
            viewModel = createViewModel(notificationSettings = NotificationSettings(enabled = false))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.ToggleNotification)
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setNotificationSettings(match { it.enabled }) }
        }

        @Test
        fun `UpdateNotificationInterval 시 알림 간격이 저장된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.UpdateNotificationInterval(90))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify { settingsRepository.setNotificationSettings(match { it.intervalMinutes == 90 }) }
        }

        @Test
        fun `UpdateNotificationTime 시 알림 시간대가 저장된다`() = runTest {
            viewModel = createViewModel()
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.onEvent(SettingsEvent.UpdateNotificationTime(startHour = 8, endHour = 22))
            testDispatcher.scheduler.advanceUntilIdle()

            coVerify {
                settingsRepository.setNotificationSettings(match {
                    it.startHour == 8 && it.endHour == 22
                })
            }
        }
    }

    @Nested
    @DisplayName("UI 상태")
    inner class UiStateTest {
        @Test
        fun `퀵버튼 포맷이 올바르게 생성된다`() = runTest {
            viewModel = createViewModel(quickButtons = listOf(100, 200, 300, 500))
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals("100, 200, 300, 500ml", state.quickButtonsFormatted)
                cancelAndIgnoreRemainingEvents()
            }
        }

        @Test
        fun `목표량 포맷이 올바르게 생성된다`() = runTest {
            viewModel = createViewModel(goal = 2500)
            testDispatcher.scheduler.advanceUntilIdle()

            viewModel.uiState.test {
                val state = awaitItem()
                assertEquals("2500ml", state.goalFormatted)
                cancelAndIgnoreRemainingEvents()
            }
        }
    }
}
