package com.onceagain.drinksomewater.core.data.repository

import com.onceagain.drinksomewater.core.data.datastore.WaterDataStore
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.just
import io.mockk.mockk
import io.mockk.Runs
import kotlinx.coroutines.test.runTest
import kotlinx.datetime.LocalDate
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

class WaterRepositoryImplTest {

    private val dataStore: WaterDataStore = mockk()
    private lateinit var repository: WaterRepositoryImpl

    private val today = LocalDate(2026, 1, 20)
    
    private fun createRecord(
        date: LocalDate = today,
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
        repository = WaterRepositoryImpl(dataStore)
    }

    @Nested
    @DisplayName("getTodayRecord")
    inner class GetTodayRecordTest {
        @Test
        fun `오늘 기록이 있으면 반환한다`() = runTest {
            val todayRecord = createRecord(value = 500)
            coEvery { dataStore.getTodayRecord() } returns todayRecord

            val result = repository.getTodayRecord()

            assertEquals(todayRecord, result)
        }

        @Test
        fun `오늘 기록이 없으면 새로 생성한다`() = runTest {
            coEvery { dataStore.getTodayRecord() } returns null
            coEvery { dataStore.getGoal() } returns 2000
            coEvery { dataStore.saveRecord(any()) } just Runs

            val result = repository.getTodayRecord()

            assertNotNull(result)
            assertEquals(0, result?.value)
            assertEquals(2000, result?.goal)
            coVerify { dataStore.saveRecord(any()) }
        }
    }

    @Nested
    @DisplayName("getAllRecords")
    inner class GetAllRecordsTest {
        @Test
        fun `전체 기록을 날짜 역순으로 반환한다`() = runTest {
            val records = listOf(
                createRecord(date = LocalDate(2026, 1, 18), value = 1500),
                createRecord(date = LocalDate(2026, 1, 20), value = 2000),
                createRecord(date = LocalDate(2026, 1, 19), value = 1800)
            )
            coEvery { dataStore.getAllRecords() } returns records

            val result = repository.getAllRecords()

            assertEquals(LocalDate(2026, 1, 20), result[0].date)
            assertEquals(LocalDate(2026, 1, 19), result[1].date)
            assertEquals(LocalDate(2026, 1, 18), result[2].date)
        }
    }

    @Nested
    @DisplayName("getGoal")
    inner class GetGoalTest {
        @Test
        fun `저장된 목표량을 반환한다`() = runTest {
            coEvery { dataStore.getGoal() } returns 2500

            val result = repository.getGoal()

            assertEquals(2500, result)
        }
    }

    @Nested
    @DisplayName("addWater")
    inner class AddWaterTest {
        @Test
        fun `현재 값에 양이 추가된다`() = runTest {
            val currentRecord = createRecord(value = 500)
            coEvery { dataStore.getTodayRecord() } returns currentRecord
            coEvery { dataStore.getGoal() } returns 2000
            coEvery { dataStore.saveRecord(any()) } just Runs

            repository.addWater(300)

            coVerify {
                dataStore.saveRecord(match { it.value == 800 })
            }
        }

        @Test
        fun `목표 달성 시 isSuccess가 true가 된다`() = runTest {
            val currentRecord = createRecord(value = 1800, isSuccess = false)
            coEvery { dataStore.getTodayRecord() } returns currentRecord
            coEvery { dataStore.getGoal() } returns 2000
            coEvery { dataStore.saveRecord(any()) } just Runs

            repository.addWater(300)

            coVerify {
                dataStore.saveRecord(match { it.isSuccess })
            }
        }
    }

    @Nested
    @DisplayName("subtractWater")
    inner class SubtractWaterTest {
        @Test
        fun `현재 값에서 양이 빠진다`() = runTest {
            val currentRecord = createRecord(value = 500)
            coEvery { dataStore.getTodayRecord() } returns currentRecord
            coEvery { dataStore.getGoal() } returns 2000
            coEvery { dataStore.saveRecord(any()) } just Runs

            repository.subtractWater(200)

            coVerify {
                dataStore.saveRecord(match { it.value == 300 })
            }
        }

        @Test
        fun `음수가 되지 않는다`() = runTest {
            val currentRecord = createRecord(value = 100)
            coEvery { dataStore.getTodayRecord() } returns currentRecord
            coEvery { dataStore.getGoal() } returns 2000
            coEvery { dataStore.saveRecord(any()) } just Runs

            repository.subtractWater(200)

            coVerify {
                dataStore.saveRecord(match { it.value == 0 })
            }
        }
    }

    @Nested
    @DisplayName("resetToday")
    inner class ResetTodayTest {
        @Test
        fun `오늘 기록이 0으로 초기화된다`() = runTest {
            val currentRecord = createRecord(value = 1500, isSuccess = true)
            coEvery { dataStore.getTodayRecord() } returns currentRecord
            coEvery { dataStore.getGoal() } returns 2000
            coEvery { dataStore.saveRecord(any()) } just Runs

            repository.resetToday()

            coVerify {
                dataStore.saveRecord(match { it.value == 0 && !it.isSuccess })
            }
        }
    }

    @Nested
    @DisplayName("updateGoal")
    inner class UpdateGoalTest {
        @Test
        fun `목표량이 변경된다`() = runTest {
            coEvery { dataStore.setGoal(any()) } just Runs
            coEvery { dataStore.getTodayRecord() } returns createRecord(value = 1500)
            coEvery { dataStore.getGoal() } returns 2500
            coEvery { dataStore.saveRecord(any()) } just Runs

            repository.updateGoal(2500)

            coVerify { dataStore.setGoal(2500) }
        }

        @Test
        fun `오늘 기록의 goal도 업데이트된다`() = runTest {
            coEvery { dataStore.setGoal(any()) } just Runs
            coEvery { dataStore.getTodayRecord() } returns createRecord(value = 1500, goal = 2000)
            coEvery { dataStore.getGoal() } returns 1500
            coEvery { dataStore.saveRecord(any()) } just Runs

            repository.updateGoal(1500)

            coVerify {
                dataStore.saveRecord(match { it.goal == 1500 && it.isSuccess })
            }
        }
    }
}
