package com.onceagain.drinksomewater.wear.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
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
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import com.onceagain.drinksomewater.wear.R

@Composable
fun QuickAddScreen(
    onBack: () -> Unit,
    viewModel: WatchViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    QuickAddContent(
        buttons = uiState.quickButtons,
        onAddWater = {
            viewModel.onEvent(WatchEvent.AddWater(it))
            onBack()
        }
    )
}

@Composable
private fun QuickAddContent(
    buttons: List<Int>,
    onAddWater: (Int) -> Unit
) {
    Scaffold(
        timeText = { TimeText() }
    ) {
        ScalingLazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            autoCentering = AutoCenteringParams(itemIndex = 1)
        ) {
            item {
                Text(
                    text = stringResource(R.string.wear_quick_add),
                    style = MaterialTheme.typography.title3,
                    fontWeight = FontWeight.Bold
                )
            }
            buttons.forEach { amount ->
                item {
                    Button(
                        onClick = { onAddWater(amount) },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = "+${amount}ml",
                            style = MaterialTheme.typography.body2,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}
