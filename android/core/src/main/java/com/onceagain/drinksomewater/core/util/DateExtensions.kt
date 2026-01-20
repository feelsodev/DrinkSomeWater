package com.onceagain.drinksomewater.core.util

import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

fun LocalDate.Companion.today(): LocalDate {
    return Clock.System.now()
        .toLocalDateTime(TimeZone.currentSystemDefault())
        .date
}

fun LocalDate.isToday(): Boolean {
    return this == LocalDate.today()
}

fun LocalDate.formatDisplay(): String {
    return "${year}년 ${monthNumber}월 ${dayOfMonth}일"
}

fun LocalDate.formatShort(): String {
    return "${monthNumber}/${dayOfMonth}"
}
