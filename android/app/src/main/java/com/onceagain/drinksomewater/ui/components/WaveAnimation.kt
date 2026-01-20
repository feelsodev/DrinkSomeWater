package com.onceagain.drinksomewater.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.clipPath
import com.onceagain.drinksomewater.ui.theme.DS
import kotlin.math.PI
import kotlin.math.sin

@Composable
fun WaveAnimation(
    progress: Float,
    isGoalAchieved: Boolean,
    modifier: Modifier = Modifier
) {
    val clampedProgress = progress.coerceIn(0f, 1f)

    val infiniteTransition = rememberInfiniteTransition(label = "wave")

    val waveOffset by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 2 * PI.toFloat(),
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 2000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "waveOffset"
    )

    val backColor = if (isGoalAchieved) DS.Colors.waveSuccessBack else DS.Colors.waveBack
    val frontColor = if (isGoalAchieved) DS.Colors.waveSuccessFront else DS.Colors.waveFront

    Canvas(modifier = modifier.fillMaxSize()) {
        val width = size.width
        val height = size.height
        val radius = minOf(width, height) / 2f

        val circlePath = Path().apply {
            addOval(
                androidx.compose.ui.geometry.Rect(
                    center = Offset(width / 2f, height / 2f),
                    radius = radius
                )
            )
        }

        drawCircle(
            color = DS.Colors.backgroundTertiary,
            radius = radius,
            center = Offset(width / 2f, height / 2f)
        )

        clipPath(circlePath) {
            val waterLevel = height - (height * clampedProgress)

            drawWave(
                waveOffset = waveOffset + PI.toFloat() / 2,
                waterLevel = waterLevel + 10f,
                amplitude = 12f,
                color = backColor,
                width = width,
                height = height
            )

            drawWave(
                waveOffset = waveOffset,
                waterLevel = waterLevel,
                amplitude = 15f,
                color = frontColor,
                width = width,
                height = height
            )
        }

        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color.White.copy(alpha = 0.3f),
                    Color.Transparent
                ),
                center = Offset(width * 0.35f, height * 0.35f),
                radius = radius * 0.4f
            ),
            radius = radius,
            center = Offset(width / 2f, height / 2f)
        )
    }
}

private fun DrawScope.drawWave(
    waveOffset: Float,
    waterLevel: Float,
    amplitude: Float,
    color: Color,
    width: Float,
    height: Float
) {
    val wavePath = Path()

    wavePath.moveTo(0f, height)

    for (x in 0..width.toInt()) {
        val y = waterLevel + amplitude * sin((x / width * 2 * PI + waveOffset).toFloat())
        if (x == 0) {
            wavePath.moveTo(x.toFloat(), y)
        } else {
            wavePath.lineTo(x.toFloat(), y)
        }
    }

    wavePath.lineTo(width, height)
    wavePath.lineTo(0f, height)
    wavePath.close()

    drawPath(
        path = wavePath,
        color = color
    )
}
