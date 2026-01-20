package com.onceagain.drinksomewater.service.ad

import android.content.Context
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdOptions
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class NativeAdHelper @Inject constructor(
    @ApplicationContext private val context: Context
) {
    companion object {
        const val TEST_AD_UNIT_ID = "ca-app-pub-3940256099942544/2247696110"
    }

    private var currentAd: NativeAd? = null

    fun loadNativeAd(adUnitId: String = TEST_AD_UNIT_ID): Flow<NativeAdState> = callbackFlow {
        trySend(NativeAdState.Loading)

        val adLoader = AdLoader.Builder(context, adUnitId)
            .forNativeAd { ad ->
                currentAd?.destroy()
                currentAd = ad
                trySend(NativeAdState.Loaded(ad))
            }
            .withAdListener(object : AdListener() {
                override fun onAdFailedToLoad(error: LoadAdError) {
                    trySend(NativeAdState.Error(error.message))
                }
            })
            .withNativeAdOptions(
                NativeAdOptions.Builder()
                    .setAdChoicesPlacement(NativeAdOptions.ADCHOICES_TOP_RIGHT)
                    .build()
            )
            .build()

        adLoader.loadAd(AdRequest.Builder().build())

        awaitClose {
            currentAd?.destroy()
            currentAd = null
        }
    }

    fun destroyAd() {
        currentAd?.destroy()
        currentAd = null
    }
}

sealed interface NativeAdState {
    data object Loading : NativeAdState
    data class Loaded(val ad: NativeAd) : NativeAdState
    data class Error(val message: String) : NativeAdState
}
