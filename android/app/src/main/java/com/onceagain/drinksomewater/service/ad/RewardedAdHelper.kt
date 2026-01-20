package com.onceagain.drinksomewater.service.ad

import android.app.Activity
import android.content.Context
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class RewardedAdHelper @Inject constructor(
    @ApplicationContext private val context: Context
) {
    companion object {
        const val TEST_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"
    }

    private var rewardedAd: RewardedAd? = null
    private val _isAdLoaded = MutableStateFlow(false)
    val isAdLoaded: StateFlow<Boolean> = _isAdLoaded.asStateFlow()

    fun loadRewardedAd(adUnitId: String = TEST_AD_UNIT_ID) {
        if (rewardedAd != null) return

        RewardedAd.load(
            context,
            adUnitId,
            AdRequest.Builder().build(),
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedAd = ad
                    _isAdLoaded.value = true
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    rewardedAd = null
                    _isAdLoaded.value = false
                }
            }
        )
    }

    fun showRewardedAd(activity: Activity): Flow<RewardedAdResult> = callbackFlow {
        val ad = rewardedAd
        if (ad == null) {
            trySend(RewardedAdResult.NotReady)
            close()
            return@callbackFlow
        }

        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                rewardedAd = null
                _isAdLoaded.value = false
                loadRewardedAd()
            }

            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                trySend(RewardedAdResult.Error(error.message))
                rewardedAd = null
                _isAdLoaded.value = false
                close()
            }
        }

        ad.show(activity) { rewardItem ->
            trySend(
                RewardedAdResult.Rewarded(
                    type = rewardItem.type,
                    amount = rewardItem.amount
                )
            )
            close()
        }

        awaitClose()
    }
}

sealed interface RewardedAdResult {
    data object NotReady : RewardedAdResult
    data class Rewarded(val type: String, val amount: Int) : RewardedAdResult
    data class Error(val message: String) : RewardedAdResult
}
