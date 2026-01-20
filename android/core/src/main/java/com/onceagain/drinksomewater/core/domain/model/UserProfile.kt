package com.onceagain.drinksomewater.core.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class UserProfile(
    val weightKg: Float = DEFAULT_WEIGHT_KG,
    val useHealthConnect: Boolean = false,
    val onboardingCompleted: Boolean = false
) {
    val recommendedIntakeMl: Int
        get() = (weightKg * ML_PER_KG).toInt()

    companion object {
        const val DEFAULT_WEIGHT_KG = 65f
        const val ML_PER_KG = 33f
        const val MIN_GOAL_ML = 1000
        const val MAX_GOAL_ML = 4500
    }
}
