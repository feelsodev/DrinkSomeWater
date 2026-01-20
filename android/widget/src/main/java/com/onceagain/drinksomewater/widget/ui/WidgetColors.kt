package com.onceagain.drinksomewater.widget.ui

import androidx.compose.ui.graphics.Color
import androidx.glance.unit.ColorProvider

object WidgetColors {
    val Primary = Color(0xFF59BFF2)
    val Success = Color(0xFF5AC89E)
    val TextPrimary = Color(0xFF333340)
    val TextSecondary = Color(0xFF6B6B80)
    val ButtonBackground = Color(0xFFF0F4F8)
}

fun colorProvider(color: Color): ColorProvider = ColorProvider(color)
