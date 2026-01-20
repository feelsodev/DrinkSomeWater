package com.onceagain.drinksomewater.core.domain.model

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

class UserProfileTest {

    @Nested
    @DisplayName("권장 섭취량 계산")
    inner class RecommendedIntakeTest {
        @Test
        fun `recommendedIntakeMl은 체중에 33을 곱한 값이다`() {
            val profile = UserProfile(weightKg = 70f)
            assertEquals(2310, profile.recommendedIntakeMl)
        }

        @Test
        fun `기본 체중은 65kg이다`() {
            val profile = UserProfile()
            assertEquals(65f, profile.weightKg)
        }

        @Test
        fun `기본 권장량은 2145ml이다`() {
            val profile = UserProfile()
            assertEquals(2145, profile.recommendedIntakeMl)
        }

        @Test
        fun `체중이 0이면 권장량은 0이다`() {
            val profile = UserProfile(weightKg = 0f)
            assertEquals(0, profile.recommendedIntakeMl)
        }

        @Test
        fun `체중이 50kg이면 권장량은 1650ml이다`() {
            val profile = UserProfile(weightKg = 50f)
            assertEquals(1650, profile.recommendedIntakeMl)
        }
    }

    @Nested
    @DisplayName("기본값")
    inner class DefaultValuesTest {
        @Test
        fun `useHealthConnect 기본값은 false이다`() {
            val profile = UserProfile()
            assertEquals(false, profile.useHealthConnect)
        }

        @Test
        fun `onboardingCompleted 기본값은 false이다`() {
            val profile = UserProfile()
            assertEquals(false, profile.onboardingCompleted)
        }
    }

    @Nested
    @DisplayName("목표량 범위 상수")
    inner class GoalRangeTest {
        @Test
        fun `MIN_GOAL_ML은 1000이다`() {
            assertEquals(1000, UserProfile.MIN_GOAL_ML)
        }

        @Test
        fun `MAX_GOAL_ML은 4500이다`() {
            assertEquals(4500, UserProfile.MAX_GOAL_ML)
        }
    }
}
