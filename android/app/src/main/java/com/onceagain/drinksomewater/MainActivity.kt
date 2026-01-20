package com.onceagain.drinksomewater

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.onceagain.drinksomewater.core.domain.repository.SettingsRepository
import com.onceagain.drinksomewater.ui.navigation.AppNavigation
import com.onceagain.drinksomewater.ui.theme.DrinkSomeWaterTheme
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var settingsRepository: SettingsRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            DrinkSomeWaterTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainContent(settingsRepository = settingsRepository)
                }
            }
        }
    }
}

@Composable
private fun MainContent(
    settingsRepository: SettingsRepository
) {
    var isLoading by remember { mutableStateOf(true) }
    var showOnboarding by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        showOnboarding = !settingsRepository.isOnboardingCompleted()
        isLoading = false
    }

    if (isLoading) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
    } else {
        AppNavigation(showOnboarding = showOnboarding)
    }
}
