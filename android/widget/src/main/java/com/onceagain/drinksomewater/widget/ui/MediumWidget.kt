package com.onceagain.drinksomewater.widget.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
import androidx.glance.appwidget.CircularProgressIndicator
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.onceagain.drinksomewater.widget.action.AddWaterAction
import com.onceagain.drinksomewater.widget.data.WaterWidgetState

@Composable
fun MediumWidget(state: WaterWidgetState) {
    val progressColor = if (state.isGoalAchieved) WidgetColors.Success else WidgetColors.Primary
    
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(GlanceTheme.colors.background)
            .cornerRadius(16.dp)
    ) {
        Row(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = GlanceModifier.width(80.dp)
            ) {
                Box(
                    modifier = GlanceModifier.size(60.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(
                        modifier = GlanceModifier.size(60.dp),
                        color = colorProvider(progressColor)
                    )
                    
                    Text(
                        text = "${state.progressPercent}%",
                        style = TextStyle(
                            color = colorProvider(WidgetColors.TextPrimary),
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    )
                }
                
                Text(
                    text = "${state.currentMl}ml",
                    style = TextStyle(
                        color = colorProvider(WidgetColors.TextSecondary),
                        fontSize = 11.sp
                    ),
                    modifier = GlanceModifier.padding(top = 2.dp)
                )
            }
            
            Spacer(modifier = GlanceModifier.width(8.dp))
            
            Column(
                modifier = GlanceModifier.fillMaxHeight(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    state.quickButtons.take(2).forEach { amount ->
                        QuickAddButton(
                            amount = amount,
                            textColor = colorProvider(WidgetColors.Primary),
                            backgroundColor = colorProvider(WidgetColors.ButtonBackground)
                        )
                        Spacer(modifier = GlanceModifier.width(6.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun QuickAddButton(
    amount: Int,
    textColor: ColorProvider,
    backgroundColor: ColorProvider
) {
    Box(
        modifier = GlanceModifier
            .size(width = 70.dp, height = 36.dp)
            .background(backgroundColor)
            .cornerRadius(8.dp)
            .clickable(actionRunCallback<AddWaterAction>(
                AddWaterAction.createParameters(amount)
            )),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "+${amount}ml",
            style = TextStyle(
                color = textColor,
                fontWeight = FontWeight.Medium,
                fontSize = 12.sp,
                textAlign = TextAlign.Center
            )
        )
    }
}
