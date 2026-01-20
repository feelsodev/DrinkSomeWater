package com.onceagain.drinksomewater.ui.onboarding

data class OnboardingUiState(
    val currentPage: Int = 0,
    val totalPages: Int = 5,
    val goalMl: Int = 2000,
    val isCompleted: Boolean = false
) {
    val isFirstPage: Boolean
        get() = currentPage == 0

    val isLastPage: Boolean
        get() = currentPage == totalPages - 1
}

sealed class OnboardingEvent {
    data object NextPage : OnboardingEvent()
    data object PreviousPage : OnboardingEvent()
    data class GoToPage(val page: Int) : OnboardingEvent()
    data class UpdateGoal(val goalMl: Int) : OnboardingEvent()
    data object CompleteOnboarding : OnboardingEvent()
}

enum class OnboardingPage {
    INTRO,
    GOAL_SETTING,
    HEALTH_CONNECT,
    NOTIFICATION,
    WIDGET_GUIDE
}
