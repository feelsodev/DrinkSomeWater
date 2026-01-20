package com.onceagain.drinksomewater.core.domain.model

import kotlinx.datetime.LocalDate
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

class WaterRecordTest {

    private fun createRecord(
        value: Int = 0,
        goal: Int = 2000,
        isSuccess: Boolean = value >= goal
    ) = WaterRecord(
        date = LocalDate(2026, 1, 20),
        value = value,
        isSuccess = isSuccess,
        goal = goal
    )

    @Nested
    @DisplayName("id 생성")
    inner class IdTest {
        @Test
        fun `id는 날짜 문자열로 생성된다`() {
            val record = createRecord()
            assertEquals("2026-01-20", record.id)
        }
    }

    @Nested
    @DisplayName("progress 계산")
    inner class ProgressTest {
        @Test
        fun `goal이 0일 때 progress는 0이다`() {
            val record = createRecord(value = 100, goal = 0)
            assertEquals(0f, record.progress)
        }

        @Test
        fun `value가 goal의 절반일 때 progress는 0점5이다`() {
            val record = createRecord(value = 1000, goal = 2000)
            assertEquals(0.5f, record.progress, 0.01f)
        }

        @Test
        fun `progress는 1을 초과하지 않는다`() {
            val record = createRecord(value = 3000, goal = 2000)
            assertEquals(1f, record.progress)
        }

        @Test
        fun `progressPercent는 progress에 100을 곱한 정수이다`() {
            val record = createRecord(value = 1500, goal = 2000)
            assertEquals(75, record.progressPercent)
        }
    }

    @Nested
    @DisplayName("remainingMl 계산")
    inner class RemainingMlTest {
        @Test
        fun `remainingMl은 goal에서 value를 뺀 값이다`() {
            val record = createRecord(value = 1500, goal = 2000)
            assertEquals(500, record.remainingMl)
        }

        @Test
        fun `remainingMl은 음수가 되지 않는다`() {
            val record = createRecord(value = 2500, goal = 2000)
            assertEquals(0, record.remainingMl)
        }
    }

    @Nested
    @DisplayName("remainingCups 계산")
    inner class RemainingCupsTest {
        @Test
        fun `remainingCups는 remainingMl을 250으로 나눈 값이다`() {
            val record = createRecord(value = 1500, goal = 2000)
            assertEquals(2, record.remainingCups)
        }

        @Test
        fun `remainingMl이 250 미만이면 remainingCups는 0이다`() {
            val record = createRecord(value = 1900, goal = 2000)
            assertEquals(0, record.remainingCups)
        }
    }

    @Nested
    @DisplayName("물 추가 및 빼기")
    inner class WaterOperationsTest {
        @Test
        fun `withAddedWater는 value에 양을 더한다`() {
            val record = createRecord(value = 500)
            val updated = record.withAddedWater(300)
            assertEquals(800, updated.value)
        }

        @Test
        fun `withAddedWater 후 목표 달성 시 isSuccess가 true가 된다`() {
            val record = createRecord(value = 1800, goal = 2000, isSuccess = false)
            val updated = record.withAddedWater(300)
            assertTrue(updated.isSuccess)
        }

        @Test
        fun `withSubtractedWater는 value에서 양을 뺀다`() {
            val record = createRecord(value = 500)
            val updated = record.withSubtractedWater(200)
            assertEquals(300, updated.value)
        }

        @Test
        fun `withSubtractedWater는 음수가 되지 않는다`() {
            val record = createRecord(value = 100)
            val updated = record.withSubtractedWater(200)
            assertEquals(0, updated.value)
        }
    }

    @Nested
    @DisplayName("초기화 및 목표 변경")
    inner class ResetAndGoalTest {
        @Test
        fun `withReset은 value를 0으로 초기화한다`() {
            val record = createRecord(value = 1500, isSuccess = true)
            val updated = record.withReset()
            assertEquals(0, updated.value)
            assertFalse(updated.isSuccess)
        }

        @Test
        fun `withGoal은 목표량을 변경한다`() {
            val record = createRecord(value = 1500, goal = 2000)
            val updated = record.withGoal(1500)
            assertEquals(1500, updated.goal)
            assertTrue(updated.isSuccess)
        }
    }
}
