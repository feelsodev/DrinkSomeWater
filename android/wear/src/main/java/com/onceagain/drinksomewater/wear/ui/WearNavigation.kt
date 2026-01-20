package com.onceagain.drinksomewater.wear.ui

import androidx.compose.runtime.Composable
import androidx.wear.compose.navigation.SwipeDismissableNavHost
import androidx.wear.compose.navigation.composable
import androidx.wear.compose.navigation.rememberSwipeDismissableNavController

private object WearRoutes {
    const val Home = "home"
    const val QuickAdd = "quick_add"
    const val CustomAmount = "custom_amount"
}

@Composable
fun WearNavigation() {
    val navController = rememberSwipeDismissableNavController()

    SwipeDismissableNavHost(
        navController = navController,
        startDestination = WearRoutes.Home
    ) {
        composable(WearRoutes.Home) {
            WatchHomeScreen(
                onNavigateQuickAdd = { navController.navigate(WearRoutes.QuickAdd) },
                onNavigateCustomAmount = { navController.navigate(WearRoutes.CustomAmount) }
            )
        }
        composable(WearRoutes.QuickAdd) {
            QuickAddScreen(onBack = { navController.popBackStack() })
        }
        composable(WearRoutes.CustomAmount) {
            CustomAmountScreen(onBack = { navController.popBackStack() })
        }
    }
}
