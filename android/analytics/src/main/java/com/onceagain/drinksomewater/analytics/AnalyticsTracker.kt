package com.onceagain.drinksomewater.analytics

import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.logEvent
import javax.inject.Inject
import javax.inject.Singleton

interface AnalyticsTracker {
    fun logEvent(event: AnalyticsEvent)
    fun logWaterIntake(amountMl: Int, method: IntakeMethod, hour: Int = currentHour())
    fun logWaterSubtracted(amountMl: Int)
    fun logWaterReset(previousAmountMl: Int)
    fun logGoalAchieved(goalMl: Int, actualMl: Int, streakDays: Int)
    fun logGoalChanged(oldGoal: Int, newGoal: Int, source: GoalChangeSource)
    fun logScreenView(screenName: String)
    fun setUserId(userId: String?)
    fun setUserProperty(name: String, value: String)
}

@Singleton
class FirebaseAnalyticsTracker @Inject constructor(
    private val firebaseAnalytics: FirebaseAnalytics
) : AnalyticsTracker {

    override fun logEvent(event: AnalyticsEvent) {
        firebaseAnalytics.logEvent(event.name) {
            event.params.forEach { (key, value) ->
                when (value) {
                    is String -> param(key, value)
                    is Int -> param(key, value.toLong())
                    is Long -> param(key, value)
                    is Double -> param(key, value)
                    is Boolean -> param(key, if (value) 1L else 0L)
                    else -> param(key, value.toString())
                }
            }
        }
    }

    override fun logWaterIntake(amountMl: Int, method: IntakeMethod, hour: Int) {
        logEvent(AnalyticsEvent.WaterIntake(amountMl, method, hour))
    }

    override fun logWaterSubtracted(amountMl: Int) {
        logEvent(AnalyticsEvent.WaterSubtracted(amountMl))
    }

    override fun logWaterReset(previousAmountMl: Int) {
        logEvent(AnalyticsEvent.WaterReset(previousAmountMl))
    }

    override fun logGoalAchieved(goalMl: Int, actualMl: Int, streakDays: Int) {
        logEvent(AnalyticsEvent.GoalAchieved(goalMl, actualMl, streakDays))
    }

    override fun logGoalChanged(oldGoal: Int, newGoal: Int, source: GoalChangeSource) {
        logEvent(AnalyticsEvent.GoalChanged(oldGoal, newGoal, source))
    }

    override fun logScreenView(screenName: String) {
        logEvent(AnalyticsEvent.ScreenView(screenName))
    }

    override fun setUserId(userId: String?) {
        firebaseAnalytics.setUserId(userId)
    }

    override fun setUserProperty(name: String, value: String) {
        firebaseAnalytics.setUserProperty(name, value)
    }
}

private fun currentHour(): Int {
    return java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)
}
