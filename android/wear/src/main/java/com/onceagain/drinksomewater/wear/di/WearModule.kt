package com.onceagain.drinksomewater.wear.di

import android.content.Context
import com.onceagain.drinksomewater.core.data.datastore.WaterDataStore
import com.onceagain.drinksomewater.core.data.repository.WaterRepositoryImpl
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WearModule {

    @Provides
    @Singleton
    fun provideWaterDataStore(
        @ApplicationContext context: Context
    ): WaterDataStore {
        return WaterDataStore(context)
    }

    @Provides
    @Singleton
    fun provideWaterRepository(
        dataStore: WaterDataStore
    ): WaterRepository {
        return WaterRepositoryImpl(dataStore)
    }
}
