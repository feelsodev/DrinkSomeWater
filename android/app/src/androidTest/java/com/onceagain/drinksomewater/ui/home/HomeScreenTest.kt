package com.onceagain.drinksomewater.ui.home

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.onceagain.drinksomewater.ui.theme.DrinkSomeWaterTheme
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test

@HiltAndroidTest
class HomeScreenTest {

    @get:Rule(order = 0)
    val hiltRule = HiltAndroidRule(this)

    @get:Rule(order = 1)
    val composeTestRule = createComposeRule()

    @Before
    fun setup() {
        hiltRule.inject()
    }

    @Test
    fun homeScreen_displaysTitle() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = HomeUiState(),
                    onEvent = {}
                )
            }
        }

        composeTestRule
            .onNodeWithText("오늘의 물 섭취")
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysProgressAt50Percent_when1000mlOf2000mlGoal() {
        val uiState = HomeUiState(
            currentMl = 1000,
            goalMl = 2000,
            isLoading = false
        )

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = {}
                )
            }
        }

        composeTestRule
            .onNodeWithText("50%")
            .assertIsDisplayed()

        composeTestRule
            .onNodeWithText("1000ml / 2000ml")
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysGoalAchieved_whenCurrentMlExceedsGoal() {
        val uiState = HomeUiState(
            currentMl = 2500,
            goalMl = 2000,
            isLoading = false
        )

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = {}
                )
            }
        }

        composeTestRule
            .onNodeWithText("목표 달성!", substring = true)
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysAllQuickButtons() {
        val uiState = HomeUiState(
            quickButtons = listOf(100, 200, 300, 500),
            isLoading = false
        )

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = {}
                )
            }
        }

        composeTestRule.onNodeWithText("+100ml").assertIsDisplayed()
        composeTestRule.onNodeWithText("+200ml").assertIsDisplayed()
        composeTestRule.onNodeWithText("+300ml").assertIsDisplayed()
        composeTestRule.onNodeWithText("+500ml").assertIsDisplayed()
    }

    @Test
    fun homeScreen_showsNegativeButtons_whenSubtractModeEnabled() {
        val uiState = HomeUiState(
            quickButtons = listOf(100, 200, 300, 500),
            isSubtractMode = true,
            isLoading = false
        )

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = {}
                )
            }
        }

        composeTestRule.onNodeWithText("-100ml").assertIsDisplayed()
        composeTestRule.onNodeWithText("-200ml").assertIsDisplayed()
    }

    @Test
    fun homeScreen_triggersAddWaterEvent_whenQuickButtonClicked() {
        var receivedEvent: HomeEvent? = null
        val uiState = HomeUiState(
            quickButtons = listOf(100, 200, 300, 500),
            isLoading = false
        )

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = { receivedEvent = it }
                )
            }
        }

        composeTestRule.onNodeWithText("+200ml").performClick()

        assert(receivedEvent is HomeEvent.AddWater)
        assert((receivedEvent as HomeEvent.AddWater).amount == 200)
    }

    @Test
    fun homeScreen_triggersSubtractWaterEvent_whenSubtractModeQuickButtonClicked() {
        var receivedEvent: HomeEvent? = null
        val uiState = HomeUiState(
            quickButtons = listOf(100, 200, 300, 500),
            isSubtractMode = true,
            isLoading = false
        )

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = { receivedEvent = it }
                )
            }
        }

        composeTestRule.onNodeWithText("-100ml").performClick()

        assert(receivedEvent is HomeEvent.SubtractWater)
        assert((receivedEvent as HomeEvent.SubtractWater).amount == 100)
    }

    @Test
    fun homeScreen_triggersToggleModeEvent_whenToggleButtonClicked() {
        var receivedEvent: HomeEvent? = null
        val uiState = HomeUiState(isLoading = false)

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = { receivedEvent = it }
                )
            }
        }

        composeTestRule.onNodeWithText("물 추가").performClick()

        assert(receivedEvent == HomeEvent.ToggleSubtractMode)
    }

    @Test
    fun homeScreen_displaysRemainingMl_whenGoalNotAchieved() {
        val uiState = HomeUiState(
            currentMl = 500,
            goalMl = 2000,
            isLoading = false
        )

        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                HomeContent(
                    uiState = uiState,
                    onEvent = {}
                )
            }
        }

        composeTestRule
            .onNodeWithText("1500ml")
            .assertIsDisplayed()
    }
}
