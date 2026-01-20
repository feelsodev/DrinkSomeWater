package com.onceagain.drinksomewater.wear.ui

import com.onceagain.drinksomewater.core.domain.model.WaterRecord

data class WatchUiState(
    val currentMl: Int = 0,
    val goalMl: Int = WaterRecord.DEFAULT_GOAL,
    val quickButtons: List<Int> = listOf(150, 250, 300, 500),
    val customAmount: Int = 250,
    val isLoading: Boolean = true
) {
    val progress: Float
        get() = if (goalMl == 0) 0f else minOf(1f, currentMl.toFloat() / goalMl)

    val progressPercent: Int
        get() = (progress * 100).toInt()

    val remainingMl: Int
        get() = maxOf(0, goalMl - currentMl)

    val isGoalAchieved: Boolean
        get() = currentMl >= goalMl
}
