package com.onceagain.drinksomewater.wear.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.wear.compose.foundation.lazy.AutoCenteringParams
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import com.onceagain.drinksomewater.wear.R

@Composable
fun WatchHomeScreen(
    onNavigateQuickAdd: () -> Unit,
    onNavigateCustomAmount: () -> Unit,
    viewModel: WatchViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    WatchHomeContent(
        uiState = uiState,
        onAddWater = { viewModel.onEvent(WatchEvent.AddWater(it)) },
        onNavigateQuickAdd = onNavigateQuickAdd,
        onNavigateCustomAmount = onNavigateCustomAmount
    )
}

@Composable
private fun WatchHomeContent(
    uiState: WatchUiState,
    onAddWater: (Int) -> Unit,
    onNavigateQuickAdd: () -> Unit,
    onNavigateCustomAmount: () -> Unit
) {
    Scaffold(
        timeText = { TimeText() }
    ) {
        ScalingLazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            autoCentering = AutoCenteringParams(itemIndex = 0)
        ) {
            item {
                ProgressSection(
                    currentMl = uiState.currentMl,
                    goalMl = uiState.goalMl,
                    progress = uiState.progress,
                    progressPercent = uiState.progressPercent
                )
            }

            item {
                Spacer(modifier = Modifier.height(4.dp))
            }

            item {
                QuickButtonsSection(
                    buttons = uiState.quickButtons,
                    onAddWater = onAddWater
                )
            }

            item {
                Spacer(modifier = Modifier.height(6.dp))
            }

            item {
                Chip(
                    onClick = onNavigateQuickAdd,
                    label = {
                        Text(text = stringResource(R.string.wear_quick_add))
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ChipDefaults.secondaryChipColors()
                )
            }

            item {
                Chip(
                    onClick = onNavigateCustomAmount,
                    label = {
                        Text(text = stringResource(R.string.wear_custom_amount))
                    },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

@Composable
private fun ProgressSection(
    currentMl: Int,
    goalMl: Int,
    progress: Float,
    progressPercent: Int
) {
    Box(
        modifier = Modifier.size(140.dp),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator(
            progress = progress,
            modifier = Modifier.fillMaxSize(),
            strokeWidth = 8.dp
        )
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "$progressPercent%",
                style = MaterialTheme.typography.title2,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "$currentMl ml",
                style = MaterialTheme.typography.body2
            )
            Text(
                text = "${stringResource(R.string.wear_goal)} $goalMl ml",
                style = MaterialTheme.typography.caption2
            )
        }
    }
}

@Composable
private fun QuickButtonsSection(
    buttons: List<Int>,
    onAddWater: (Int) -> Unit
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(6.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        buttons.chunked(2).forEach { rowButtons ->
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                rowButtons.forEach { amount ->
                    Button(
                        onClick = { onAddWater(amount) },
                        modifier = Modifier.size(56.dp)
                    ) {
                        Text(
                            text = "+${amount}ml",
                            style = MaterialTheme.typography.caption2,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}
