package com.onceagain.drinksomewater.wear.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.ui.graphics.Color
import androidx.wear.compose.material.Colors
import androidx.wear.compose.material.MaterialTheme
import dagger.hilt.android.AndroidEntryPoint

private val WearColors = Colors(
    primary = Color(0xFF5AC8FA),
    primaryVariant = Color(0xFF2E9FD7),
    secondary = Color(0xFF9EE7FF),
    secondaryVariant = Color(0xFF6CCCEB),
    error = Color(0xFFFF8A80),
    onPrimary = Color.Black,
    onSecondary = Color.Black,
    onError = Color.Black
)

@AndroidEntryPoint
class WearMainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colors = WearColors) {
                WearNavigation()
            }
        }
    }
}
