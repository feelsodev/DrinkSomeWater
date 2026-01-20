package com.onceagain.drinksomewater.widget.action

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.appwidget.action.ActionCallback
import com.onceagain.drinksomewater.widget.WaterGlanceWidget
import com.onceagain.drinksomewater.widget.data.WaterWidgetDataManager

class AddWaterAction : ActionCallback {
    
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val amount = parameters[PARAM_AMOUNT] ?: 0
        if (amount <= 0) return

        val currentState = WaterWidgetDataManager.getWidgetState(context)
        val newCurrentMl = currentState.currentMl + amount
        
        WaterWidgetDataManager.updateWidgetState(
            context = context,
            currentMl = newCurrentMl,
            goalMl = currentState.goalMl
        )
        
        WaterGlanceWidget().update(context, glanceId)
    }

    companion object {
        private val PARAM_AMOUNT = ActionParameters.Key<Int>("amount")
        
        fun createParameters(amount: Int): ActionParameters {
            return actionParametersOf(PARAM_AMOUNT to amount)
        }
    }
}
