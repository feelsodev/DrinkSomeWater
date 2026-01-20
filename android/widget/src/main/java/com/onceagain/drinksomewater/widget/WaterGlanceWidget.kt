package com.onceagain.drinksomewater.widget

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.state.PreferencesGlanceStateDefinition
import com.onceagain.drinksomewater.widget.data.WaterWidgetDataManager
import com.onceagain.drinksomewater.widget.data.WaterWidgetState
import com.onceagain.drinksomewater.widget.ui.SmallWidget
import com.onceagain.drinksomewater.widget.ui.MediumWidget
import com.onceagain.drinksomewater.widget.ui.LargeWidget
import androidx.glance.LocalSize
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp

class WaterGlanceWidget : GlanceAppWidget() {
    
    override val sizeMode = SizeMode.Responsive(
        setOf(
            SMALL_SIZE,
            MEDIUM_SIZE,
            LARGE_SIZE
        )
    )

    override val stateDefinition: GlanceStateDefinition<*> = PreferencesGlanceStateDefinition

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val widgetState = WaterWidgetDataManager.getWidgetState(context)
        
        provideContent {
            val size = LocalSize.current
            
            when {
                size.width < MEDIUM_SIZE.width -> SmallWidget(state = widgetState)
                size.width < LARGE_SIZE.width -> MediumWidget(state = widgetState)
                else -> LargeWidget(state = widgetState)
            }
        }
    }
    
    companion object {
        val SMALL_SIZE = DpSize(100.dp, 100.dp)
        val MEDIUM_SIZE = DpSize(250.dp, 100.dp)
        val LARGE_SIZE = DpSize(250.dp, 250.dp)
    }
}

class WaterWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = WaterGlanceWidget()
}
