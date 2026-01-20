package com.onceagain.drinksomewater.di

import android.content.Context
import com.google.firebase.analytics.FirebaseAnalytics
import com.onceagain.drinksomewater.analytics.AnalyticsTracker
import com.onceagain.drinksomewater.analytics.FirebaseAnalyticsTracker
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AnalyticsModule {

    @Provides
    @Singleton
    fun provideFirebaseAnalytics(
        @ApplicationContext context: Context
    ): FirebaseAnalytics {
        return FirebaseAnalytics.getInstance(context)
    }

    @Provides
    @Singleton
    fun provideAnalyticsTracker(
        firebaseAnalytics: FirebaseAnalytics
    ): AnalyticsTracker {
        return FirebaseAnalyticsTracker(firebaseAnalytics)
    }
}
