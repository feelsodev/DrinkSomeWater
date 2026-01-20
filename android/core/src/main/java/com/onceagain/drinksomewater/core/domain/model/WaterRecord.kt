package com.onceagain.drinksomewater.core.domain.model

import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import kotlinx.serialization.Serializable
import kotlin.math.max
import kotlin.math.min

@Serializable
data class WaterRecord(
    val date: LocalDate,
    val value: Int,
    val isSuccess: Boolean,
    val goal: Int
) {
    val id: String get() = date.toString()

    val progress: Float
        get() = if (goal == 0) 0f else min(1f, value.toFloat() / goal)

    val progressPercent: Int
        get() = (progress * 100).toInt()

    val remainingMl: Int
        get() = max(0, goal - value)

    val remainingCups: Int
        get() = remainingMl / CUP_SIZE_ML

    fun withAddedWater(amount: Int): WaterRecord {
        val newValue = value + amount
        return copy(
            value = newValue,
            isSuccess = newValue >= goal
        )
    }

    fun withSubtractedWater(amount: Int): WaterRecord {
        val newValue = max(0, value - amount)
        return copy(
            value = newValue,
            isSuccess = newValue >= goal
        )
    }

    fun withReset(): WaterRecord = copy(
        value = 0,
        isSuccess = false
    )

    fun withGoal(newGoal: Int): WaterRecord = copy(
        goal = newGoal,
        isSuccess = value >= newGoal
    )

    companion object {
        const val CUP_SIZE_ML = 250
        const val DEFAULT_GOAL = 2000

        fun createForToday(goal: Int = DEFAULT_GOAL): WaterRecord {
            return WaterRecord(
                date = Clock.System.now()
                    .toLocalDateTime(TimeZone.currentSystemDefault())
                    .date,
                value = 0,
                isSuccess = false,
                goal = goal
            )
        }
    }
}

@Serializable
data class WaterRecordsWrapper(
    val version: Int = 1,
    val records: List<WaterRecord>
)
