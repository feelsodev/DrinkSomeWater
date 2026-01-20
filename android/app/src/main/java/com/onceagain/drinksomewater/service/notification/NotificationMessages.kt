package com.onceagain.drinksomewater.service.notification

import android.content.Context
import com.onceagain.drinksomewater.R

object NotificationMessages {
    
    fun getMessages(context: Context): List<String> = listOf(
        context.getString(R.string.notification_message_1),
        context.getString(R.string.notification_message_2),
        context.getString(R.string.notification_message_3),
        context.getString(R.string.notification_message_4),
        context.getString(R.string.notification_message_5),
        context.getString(R.string.notification_message_6),
        context.getString(R.string.notification_message_7),
        context.getString(R.string.notification_message_8),
        context.getString(R.string.notification_message_9),
        context.getString(R.string.notification_message_10)
    )
    
    fun getRandomMessage(context: Context): String {
        val messages = getMessages(context)
        return messages.randomOrNull() ?: messages.first()
    }
}
