package com.onceagain.drinksomewater.ui.navigation

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
class NavigationTest {

    @get:Rule(order = 0)
    val hiltRule = HiltAndroidRule(this)

    @get:Rule(order = 1)
    val composeTestRule = createComposeRule()

    @Before
    fun setup() {
        hiltRule.inject()
    }

    @Test
    fun appNavigation_startsAtHomeScreen_whenOnboardingCompleted() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                AppNavigation(showOnboarding = false)
            }
        }

        composeTestRule
            .onNodeWithText("오늘의 물 섭취")
            .assertIsDisplayed()

        composeTestRule
            .onNodeWithText("오늘")
            .assertIsDisplayed()
    }

    @Test
    fun appNavigation_startsAtOnboardingScreen_whenOnboardingNotCompleted() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                AppNavigation(showOnboarding = true)
            }
        }

        composeTestRule
            .onNodeWithText("환영합니다!")
            .assertIsDisplayed()
    }

    @Test
    fun appNavigation_navigatesToHistoryScreen_whenHistoryTabClicked() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                AppNavigation(showOnboarding = false)
            }
        }

        composeTestRule.onNodeWithText("기록").performClick()

        composeTestRule
            .onNodeWithText("물 섭취 기록")
            .assertIsDisplayed()
    }

    @Test
    fun appNavigation_navigatesToSettingsScreen_whenSettingsTabClicked() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                AppNavigation(showOnboarding = false)
            }
        }

        composeTestRule.onNodeWithText("설정").performClick()

        composeTestRule
            .onNodeWithText("일일 목표량")
            .assertIsDisplayed()
    }

    @Test
    fun appNavigation_navigatesBackToHomeScreen_whenHomeTabClickedFromHistory() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                AppNavigation(showOnboarding = false)
            }
        }

        composeTestRule.onNodeWithText("기록").performClick()
        composeTestRule.onNodeWithText("오늘").performClick()

        composeTestRule
            .onNodeWithText("오늘의 물 섭취")
            .assertIsDisplayed()
    }

    @Test
    fun bottomNavigation_displaysAllThreeTabs() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                AppNavigation(showOnboarding = false)
            }
        }

        composeTestRule.onNodeWithText("오늘").assertIsDisplayed()
        composeTestRule.onNodeWithText("기록").assertIsDisplayed()
        composeTestRule.onNodeWithText("설정").assertIsDisplayed()
    }

    @Test
    fun bottomNavigation_isHidden_duringOnboarding() {
        composeTestRule.setContent {
            DrinkSomeWaterTheme {
                AppNavigation(showOnboarding = true)
            }
        }

        composeTestRule
            .onNodeWithText("오늘")
            .assertDoesNotExist()
    }
}
