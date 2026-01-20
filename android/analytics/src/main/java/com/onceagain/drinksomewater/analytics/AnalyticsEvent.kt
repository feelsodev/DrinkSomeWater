package com.onceagain.drinksomewater.analytics

sealed class AnalyticsEvent(
    val name: String,
    val params: Map<String, Any> = emptyMap()
) {
    data class WaterIntake(
        val amountMl: Int,
        val method: IntakeMethod,
        val hour: Int
    ) : AnalyticsEvent(
        name = "water_intake",
        params = mapOf(
            "amount_ml" to amountMl,
            "method" to method.name.lowercase(),
            "hour" to hour
        )
    )

    data class WaterSubtracted(
        val amountMl: Int
    ) : AnalyticsEvent(
        name = "water_subtracted",
        params = mapOf("amount_ml" to amountMl)
    )

    data class WaterReset(
        val previousAmountMl: Int
    ) : AnalyticsEvent(
        name = "water_reset",
        params = mapOf("previous_amount_ml" to previousAmountMl)
    )

    data class GoalAchieved(
        val goalMl: Int,
        val actualMl: Int,
        val streakDays: Int
    ) : AnalyticsEvent(
        name = "goal_achieved",
        params = mapOf(
            "goal_ml" to goalMl,
            "actual_ml" to actualMl,
            "streak_days" to streakDays
        )
    )

    data class GoalChanged(
        val oldGoal: Int,
        val newGoal: Int,
        val source: GoalChangeSource
    ) : AnalyticsEvent(
        name = "goal_changed",
        params = mapOf(
            "old_goal" to oldGoal,
            "new_goal" to newGoal,
            "source" to source.name.lowercase()
        )
    )

    data class CalendarDateSelected(
        val date: String,
        val hadRecords: Boolean,
        val wasAchieved: Boolean
    ) : AnalyticsEvent(
        name = "calendar_date_selected",
        params = mapOf(
            "date" to date,
            "had_records" to hadRecords,
            "was_achieved" to wasAchieved
        )
    )

    data class ScreenView(
        val screenName: String
    ) : AnalyticsEvent(
        name = "screen_view",
        params = mapOf("screen_name" to screenName)
    )

    data class WidgetAction(
        val action: String,
        val widgetSize: String,
        val amountMl: Int
    ) : AnalyticsEvent(
        name = "widget_action",
        params = mapOf(
            "action" to action,
            "widget_size" to widgetSize,
            "amount_ml" to amountMl
        )
    )

    data class WatchAction(
        val action: String,
        val amountMl: Int
    ) : AnalyticsEvent(
        name = "watch_action",
        params = mapOf(
            "action" to action,
            "amount_ml" to amountMl
        )
    )
}

enum class IntakeMethod {
    QUICK_BUTTON,
    CUSTOM_INPUT,
    WIDGET,
    WATCH
}

enum class GoalChangeSource {
    SETTINGS,
    ONBOARDING,
    QUICK_SETTING
}
