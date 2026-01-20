package com.onceagain.drinksomewater.service.ad

import android.content.Context
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback

object AdMobHelper {

    private var appContext: Context? = null

    fun initializeAds(context: Context) {
        if (appContext == null) {
            appContext = context.applicationContext
            MobileAds.initialize(appContext!!)
        }
    }

    fun loadNativeAd(adUnitId: String, callback: (NativeAd?) -> Unit) {
        val context = appContext ?: run {
            callback(null)
            return
        }

        val adLoader = AdLoader.Builder(context, adUnitId)
            .forNativeAd { nativeAd ->
                callback(nativeAd)
            }
            .withAdListener(object : com.google.android.gms.ads.AdListener() {
                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                    callback(null)
                }
            })
            .build()

        adLoader.loadAd(AdRequest.Builder().build())
    }

    fun loadRewardedAd(adUnitId: String, callback: (RewardedAd?) -> Unit) {
        val context = appContext ?: run {
            callback(null)
            return
        }

        RewardedAd.load(
            context,
            adUnitId,
            AdRequest.Builder().build(),
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(rewardedAd: RewardedAd) {
                    callback(rewardedAd)
                }

                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                    callback(null)
                }
            }
        )
    }
}
