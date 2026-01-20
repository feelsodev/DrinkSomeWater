package com.onceagain.drinksomewater.widget.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.CircularProgressIndicator
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import com.onceagain.drinksomewater.widget.data.WaterWidgetState

@Composable
fun SmallWidget(state: WaterWidgetState) {
    val progressColor = if (state.isGoalAchieved) WidgetColors.Success else WidgetColors.Primary
    
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(GlanceTheme.colors.background)
            .cornerRadius(16.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = GlanceModifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
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
                        fontSize = 16.sp
                    )
                )
            }
            
            Text(
                text = "${state.currentMl}ml",
                style = TextStyle(
                    color = colorProvider(WidgetColors.TextSecondary),
                    fontSize = 12.sp
                ),
                modifier = GlanceModifier.padding(top = 4.dp)
            )
        }
    }
}
