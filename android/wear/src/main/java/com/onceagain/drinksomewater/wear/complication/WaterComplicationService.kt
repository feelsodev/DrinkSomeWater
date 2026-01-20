package com.onceagain.drinksomewater.wear.complication

import android.graphics.drawable.Icon
import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.MonochromaticImage
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.RangedValueComplicationData
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import com.onceagain.drinksomewater.core.domain.repository.WaterRepository
import com.onceagain.drinksomewater.wear.R
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class WaterComplicationService : SuspendingComplicationDataSourceService() {

    @Inject
    lateinit var waterRepository: WaterRepository

    override fun getPreviewData(type: ComplicationType): ComplicationData? {
        return when (type) {
            ComplicationType.SHORT_TEXT -> createShortTextPreview()
            ComplicationType.RANGED_VALUE -> createRangedValuePreview()
            else -> null
        }
    }

    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val record = waterRepository.getTodayRecord()
        val currentMl = record?.value ?: 0
        val goalMl = record?.goal ?: 2000
        val progress = if (goalMl > 0) currentMl.toFloat() / goalMl else 0f

        return when (request.complicationType) {
            ComplicationType.SHORT_TEXT -> createShortTextComplication(currentMl, goalMl)
            ComplicationType.RANGED_VALUE -> createRangedValueComplication(currentMl, goalMl, progress)
            else -> null
        }
    }

    private fun createShortTextPreview(): ComplicationData {
        return ShortTextComplicationData.Builder(
            text = PlainComplicationText.Builder("1000ml").build(),
            contentDescription = PlainComplicationText.Builder("Water intake").build()
        )
            .setMonochromaticImage(
                MonochromaticImage.Builder(
                    Icon.createWithResource(this, R.drawable.ic_water_drop)
                ).build()
            )
            .build()
    }

    private fun createRangedValuePreview(): ComplicationData {
        return RangedValueComplicationData.Builder(
            value = 50f,
            min = 0f,
            max = 100f,
            contentDescription = PlainComplicationText.Builder("Water intake progress").build()
        )
            .setText(PlainComplicationText.Builder("50%").build())
            .setMonochromaticImage(
                MonochromaticImage.Builder(
                    Icon.createWithResource(this, R.drawable.ic_water_drop)
                ).build()
            )
            .build()
    }

    private fun createShortTextComplication(currentMl: Int, goalMl: Int): ComplicationData {
        val displayText = if (currentMl >= 1000) {
            "${currentMl / 1000}.${(currentMl % 1000) / 100}L"
        } else {
            "${currentMl}ml"
        }

        return ShortTextComplicationData.Builder(
            text = PlainComplicationText.Builder(displayText).build(),
            contentDescription = PlainComplicationText.Builder(
                "Water intake: $currentMl of $goalMl ml"
            ).build()
        )
            .setMonochromaticImage(
                MonochromaticImage.Builder(
                    Icon.createWithResource(this, R.drawable.ic_water_drop)
                ).build()
            )
            .build()
    }

    private fun createRangedValueComplication(
        currentMl: Int,
        goalMl: Int,
        progress: Float
    ): ComplicationData {
        val percentValue = (progress * 100).coerceIn(0f, 100f)

        return RangedValueComplicationData.Builder(
            value = percentValue,
            min = 0f,
            max = 100f,
            contentDescription = PlainComplicationText.Builder(
                "Water intake: ${percentValue.toInt()}% of daily goal"
            ).build()
        )
            .setText(PlainComplicationText.Builder("${percentValue.toInt()}%").build())
            .setMonochromaticImage(
                MonochromaticImage.Builder(
                    Icon.createWithResource(this, R.drawable.ic_water_drop)
                ).build()
            )
            .build()
    }
}
