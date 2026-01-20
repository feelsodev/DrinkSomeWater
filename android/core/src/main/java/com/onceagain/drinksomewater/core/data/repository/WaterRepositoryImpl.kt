package com.onceagain.drinksomewater.core.data.repository

import com.onceagain.drinksomewater.core.data.datastore.WaterDataStore
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WaterRepositoryImpl @Inject constructor(
    private val dataStore: WaterDataStore
) : WaterRepository {

    private fun today(): LocalDate {
        return Clock.System.now()
            .toLocalDateTime(TimeZone.currentSystemDefault())
            .date
    }

    override suspend fun getTodayRecord(): WaterRecord? {
        val existing = dataStore.getTodayRecord()
        if (existing != null) return existing

        val goal = dataStore.getGoal()
        val newRecord = WaterRecord.createForToday(goal)
        dataStore.saveRecord(newRecord)
        return newRecord
    }

    override suspend fun getRecord(date: LocalDate): WaterRecord? {
        return dataStore.getRecord(date)
    }

    override suspend fun getAllRecords(): List<WaterRecord> {
        return dataStore.getAllRecords().sortedByDescending { it.date }
    }

    override suspend fun getGoal(): Int {
        return dataStore.getGoal()
    }

    override suspend fun addWater(amount: Int) {
        val record = getTodayRecord() ?: return
        val updated = record.withAddedWater(amount)
        dataStore.saveRecord(updated)
    }

    override suspend fun subtractWater(amount: Int) {
        val record = getTodayRecord() ?: return
        val updated = record.withSubtractedWater(amount)
        dataStore.saveRecord(updated)
    }

    override suspend fun resetToday() {
        val record = getTodayRecord() ?: return
        val updated = record.withReset()
        dataStore.saveRecord(updated)
    }

    override suspend fun updateGoal(goal: Int) {
        dataStore.setGoal(goal)
        val record = getTodayRecord() ?: return
        val updated = record.withGoal(goal)
        dataStore.saveRecord(updated)
    }

    override fun observeTodayRecord(): Flow<WaterRecord?> {
        return dataStore.observeTodayRecord()
    }

    override fun observeAllRecords(): Flow<List<WaterRecord>> {
        return dataStore.observeAllRecords()
    }
}
