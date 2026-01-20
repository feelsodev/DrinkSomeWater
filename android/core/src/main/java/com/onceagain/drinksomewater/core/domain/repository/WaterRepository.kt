package com.onceagain.drinksomewater.core.domain.repository

import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import kotlinx.coroutines.flow.Flow
import kotlinx.datetime.LocalDate

interface WaterRepository {
    suspend fun getTodayRecord(): WaterRecord?
    suspend fun getRecord(date: LocalDate): WaterRecord?
    suspend fun getAllRecords(): List<WaterRecord>
    suspend fun getGoal(): Int
    suspend fun addWater(amount: Int)
    suspend fun subtractWater(amount: Int)
    suspend fun resetToday()
    suspend fun updateGoal(goal: Int)
    fun observeTodayRecord(): Flow<WaterRecord?>
    fun observeAllRecords(): Flow<List<WaterRecord>>
}
