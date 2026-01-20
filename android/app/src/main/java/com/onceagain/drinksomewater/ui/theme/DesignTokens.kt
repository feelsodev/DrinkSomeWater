package com.onceagain.drinksomewater.ui.theme

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

object DS {

    object Spacing {
        val none: Dp = 0.dp
        val xxs: Dp = 4.dp
        val xs: Dp = 8.dp
        val sm: Dp = 12.dp
        val md: Dp = 16.dp
        val lg: Dp = 20.dp
        val xl: Dp = 24.dp
        val xxl: Dp = 32.dp
        val xxxl: Dp = 48.dp
    }

    object Size {
        val buttonHeight: Dp = 50.dp
        val quickButtonSize: Dp = 80.dp
        val iconSmall: Dp = 16.dp
        val iconMedium: Dp = 24.dp
        val iconLarge: Dp = 32.dp
        val cornerRadiusSmall: Dp = 8.dp
        val cornerRadiusMedium: Dp = 12.dp
        val cornerRadiusLarge: Dp = 16.dp
        val cornerRadiusFull: Dp = 999.dp
        val progressSize: Dp = 200.dp
        val borderWidth: Dp = 1.dp
    }

    object Font {
        val display: TextUnit = 48.sp
        val headline: TextUnit = 32.sp
        val title: TextUnit = 24.sp
        val body: TextUnit = 16.sp
        val caption: TextUnit = 14.sp
        val small: TextUnit = 12.sp
    }

    object Colors {
        val primary = Color(0xFF59BFF2)
        val primaryLight = Color(0xFF8ED4F7)
        val primaryDark = Color(0xFF2A9FD6)

        val success = Color(0xFF5AC89E)
        val successLight = Color(0xFF8DDCBE)
        val successDark = Color(0xFF3DA87E)

        val warning = Color(0xFFFFB74D)
        val error = Color(0xFFEF5350)

        val textPrimary = Color(0xFF333340)
        val textSecondary = Color(0xFF6B6B80)
        val textTertiary = Color(0xFF9999A8)

        val backgroundPrimary = Color(0xFFF8FBFF)
        val backgroundSecondary = Color(0xFFFFFFFF)
        val backgroundTertiary = Color(0xFFF0F4F8)

        val divider = Color(0xFFE8ECF0)

        val waveBack = Color(0xFF8ED4F7)
        val waveFront = Color(0xFF59BFF2)
        val waveSuccessBack = Color(0xFF8DDCBE)
        val waveSuccessFront = Color(0xFF5AC89E)
    }
}
