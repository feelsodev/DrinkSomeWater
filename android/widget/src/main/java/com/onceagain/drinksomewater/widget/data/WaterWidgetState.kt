package com.onceagain.drinksomewater.widget.data

import kotlinx.serialization.Serializable

@Serializable
data class WaterWidgetState(
    val currentMl: Int = 0,
    val goalMl: Int = 2000,
    val quickButtons: List<Int> = listOf(150, 300, 500)
) {
    val progress: Float
        get() = if (goalMl == 0) 0f else minOf(1f, currentMl.toFloat() / goalMl)
    
    val progressPercent: Int
        get() = (progress * 100).toInt()
    
    val isGoalAchieved: Boolean
        get() = currentMl >= goalMl
}
