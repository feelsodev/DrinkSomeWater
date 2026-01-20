package com.onceagain.drinksomewater.wear.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import com.onceagain.drinksomewater.wear.R

private const val STEP_AMOUNT = 50
private const val MIN_AMOUNT = 50
private const val MAX_AMOUNT = 2000

@Composable
fun CustomAmountScreen(
    onBack: () -> Unit,
    viewModel: WatchViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    CustomAmountContent(
        amount = uiState.customAmount,
        onDecrease = {
            val next = (uiState.customAmount - STEP_AMOUNT).coerceAtLeast(MIN_AMOUNT)
            viewModel.onEvent(WatchEvent.UpdateCustomAmount(next))
        },
        onIncrease = {
            val next = (uiState.customAmount + STEP_AMOUNT).coerceAtMost(MAX_AMOUNT)
            viewModel.onEvent(WatchEvent.UpdateCustomAmount(next))
        },
        onConfirm = {
            viewModel.onEvent(WatchEvent.ConfirmCustomAmount)
            onBack()
        }
    )
}

@Composable
private fun CustomAmountContent(
    amount: Int,
    onDecrease: () -> Unit,
    onIncrease: () -> Unit,
    onConfirm: () -> Unit
) {
    Scaffold(
        timeText = { TimeText() }
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 10.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = stringResource(R.string.wear_custom_amount),
                style = MaterialTheme.typography.title3,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = "$amount ml",
                style = MaterialTheme.typography.title2,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(10.dp))
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Button(
                    onClick = onDecrease,
                    modifier = Modifier.size(56.dp)
                ) {
                    Text(text = "-50")
                }
                Button(
                    onClick = onIncrease,
                    modifier = Modifier.size(56.dp)
                ) {
                    Text(text = "+50")
                }
            }
            Spacer(modifier = Modifier.height(12.dp))
            Button(
                onClick = onConfirm,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = stringResource(R.string.wear_add),
                    style = MaterialTheme.typography.body2,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
