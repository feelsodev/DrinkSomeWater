package com.onceagain.drinksomewater.widget.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.CircularProgressIndicator
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import androidx.glance.action.clickable
import com.onceagain.drinksomewater.widget.action.AddWaterAction
import com.onceagain.drinksomewater.widget.data.WaterWidgetState

@Composable
fun LargeWidget(state: WaterWidgetState) {
    val progressColor = if (state.isGoalAchieved) WidgetColors.Success else WidgetColors.Primary

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(GlanceTheme.colors.background)
            .cornerRadius(16.dp)
    ) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = GlanceModifier.size(100.dp),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(
                    modifier = GlanceModifier.size(100.dp),
                    color = colorProvider(progressColor)
                )

                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "${state.progressPercent}%",
                        style = TextStyle(
                            color = colorProvider(WidgetColors.TextPrimary),
                            fontWeight = FontWeight.Bold,
                            fontSize = 22.sp
                        )
                    )
                    Text(
                        text = "${state.currentMl}ml",
                        style = TextStyle(
                            color = colorProvider(WidgetColors.TextSecondary),
                            fontSize = 12.sp
                        )
                    )
                }
            }

            Spacer(modifier = GlanceModifier.height(8.dp))

            Text(
                text = "목표: ${state.goalMl}ml",
                style = TextStyle(
                    color = colorProvider(WidgetColors.TextSecondary),
                    fontSize = 12.sp
                )
            )

            Spacer(modifier = GlanceModifier.height(12.dp))

            Text(
                text = getMotivationMessage(state),
                style = TextStyle(
                    color = colorProvider(WidgetColors.TextPrimary),
                    fontSize = 14.sp,
                    textAlign = TextAlign.Center
                ),
                modifier = GlanceModifier.fillMaxWidth()
            )

            Spacer(modifier = GlanceModifier.height(16.dp))

            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                state.quickButtons.take(3).forEachIndexed { index, amount ->
                    LargeQuickAddButton(
                        amount = amount,
                        textColor = colorProvider(WidgetColors.Primary),
                        backgroundColor = colorProvider(WidgetColors.ButtonBackground)
                    )
                    if (index < 2) {
                        Spacer(modifier = GlanceModifier.width(8.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun LargeQuickAddButton(
    amount: Int,
    textColor: ColorProvider,
    backgroundColor: ColorProvider
) {
    Box(
        modifier = GlanceModifier
            .size(width = 70.dp, height = 40.dp)
            .background(backgroundColor)
            .cornerRadius(10.dp)
            .clickable(
                actionRunCallback<AddWaterAction>(
                    AddWaterAction.createParameters(amount)
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "+${amount}ml",
            style = TextStyle(
                color = textColor,
                fontWeight = FontWeight.Medium,
                fontSize = 13.sp,
                textAlign = TextAlign.Center
            )
        )
    }
}

private fun getMotivationMessage(state: WaterWidgetState): String {
    return when {
        state.isGoalAchieved -> "목표 달성! 🎉"
        state.progressPercent >= 80 -> "거의 다 왔어요! 💪"
        state.progressPercent >= 50 -> "절반 이상 완료! 👍"
        state.progressPercent >= 25 -> "좋은 출발이에요! 💧"
        else -> "물 마실 시간이에요! 💧"
    }
}
