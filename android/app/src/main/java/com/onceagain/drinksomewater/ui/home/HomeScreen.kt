package com.onceagain.drinksomewater.ui.home

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.onceagain.drinksomewater.R
import com.onceagain.drinksomewater.ui.components.WaveAnimation
import com.onceagain.drinksomewater.ui.theme.DS

@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    HomeContent(
        uiState = uiState,
        onEvent = viewModel::onEvent
    )
}

@Composable
private fun HomeContent(
    uiState: HomeUiState,
    onEvent: (HomeEvent) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(DS.Spacing.md),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        HeaderSection(
            isSubtractMode = uiState.isSubtractMode,
            onToggleMode = { onEvent(HomeEvent.ToggleSubtractMode) },
            onReset = { onEvent(HomeEvent.ResetToday) }
        )

        Spacer(modifier = Modifier.height(DS.Spacing.xl))

        ProgressSection(
            currentMl = uiState.currentMl,
            goalMl = uiState.goalMl,
            progress = uiState.progress,
            isGoalAchieved = uiState.isGoalAchieved
        )

        Spacer(modifier = Modifier.height(DS.Spacing.xl))

        StatsSection(
            remainingMl = uiState.remainingMl,
            remainingCups = uiState.remainingCups,
            isGoalAchieved = uiState.isGoalAchieved
        )

        Spacer(modifier = Modifier.height(DS.Spacing.xxl))

        QuickButtonsSection(
            buttons = uiState.quickButtons,
            isSubtractMode = uiState.isSubtractMode,
            onButtonClick = { amount ->
                if (uiState.isSubtractMode) {
                    onEvent(HomeEvent.SubtractWater(amount))
                } else {
                    onEvent(HomeEvent.AddWater(amount))
                }
            }
        )
    }
}

@Composable
private fun HeaderSection(
    isSubtractMode: Boolean,
    onToggleMode: () -> Unit,
    onReset: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = stringResource(R.string.home_title),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )

        Row {
            OutlinedButton(
                onClick = onToggleMode,
                colors = if (isSubtractMode) {
                    ButtonDefaults.outlinedButtonColors(
                        containerColor = DS.Colors.error.copy(alpha = 0.1f)
                    )
                } else {
                    ButtonDefaults.outlinedButtonColors()
                }
            ) {
                Text(
                    text = if (isSubtractMode) {
                        stringResource(R.string.home_subtract_water)
                    } else {
                        stringResource(R.string.home_add_water)
                    }
                )
            }

            val resetDescription = stringResource(R.string.a11y_reset_today)
            IconButton(
                onClick = onReset,
                modifier = Modifier.semantics {
                    contentDescription = resetDescription
                }
            ) {
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = null
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
    isGoalAchieved: Boolean
) {
    val progressPercent = (progress * 100).toInt()
    val progressDescription = stringResource(R.string.a11y_progress_chart, progressPercent)
    val intakeDescription = stringResource(R.string.a11y_current_intake, currentMl, goalMl)

    Box(
        modifier = Modifier
            .size(DS.Size.progressSize)
            .semantics {
                contentDescription = "$progressDescription. $intakeDescription"
            },
        contentAlignment = Alignment.Center
    ) {
        WaveAnimation(
            progress = progress,
            isGoalAchieved = isGoalAchieved,
            modifier = Modifier.fillMaxSize()
        )

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "$progressPercent%",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Bold,
                color = if (isGoalAchieved) DS.Colors.success else DS.Colors.primary
            )
            Text(
                text = "${currentMl}ml / ${goalMl}ml",
                style = MaterialTheme.typography.bodyMedium,
                color = DS.Colors.textSecondary
            )
        }
    }
}

@Composable
private fun StatsSection(
    remainingMl: Int,
    remainingCups: Int,
    isGoalAchieved: Boolean
) {
    if (isGoalAchieved) {
        Card(
            colors = CardDefaults.cardColors(
                containerColor = DS.Colors.success.copy(alpha = 0.1f)
            ),
            shape = RoundedCornerShape(DS.Size.cornerRadiusMedium)
        ) {
            Text(
                text = "🎉 ${stringResource(R.string.home_goal_achieved)}",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = DS.Colors.success,
                modifier = Modifier.padding(DS.Spacing.md),
                textAlign = TextAlign.Center
            )
        }
    } else {
        Row(
            horizontalArrangement = Arrangement.spacedBy(DS.Spacing.xl)
        ) {
            StatItem(
                label = stringResource(R.string.home_remaining),
                value = "${remainingMl}ml"
            )
            StatItem(
                label = stringResource(R.string.home_remaining_cups),
                value = "${remainingCups}${stringResource(R.string.unit_cups)}"
            )
        }
    }
}

@Composable
private fun StatItem(
    label: String,
    value: String
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.textPrimary
        )
        Text(
            text = label,
            style = MaterialTheme.typography.bodySmall,
            color = DS.Colors.textSecondary
        )
    }
}

@Composable
private fun QuickButtonsSection(
    buttons: List<Int>,
    isSubtractMode: Boolean,
    onButtonClick: (Int) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(DS.Spacing.sm)
    ) {
        buttons.forEach { amount ->
            val buttonDescription = if (isSubtractMode) {
                stringResource(R.string.a11y_quick_button_subtract, amount)
            } else {
                stringResource(R.string.a11y_quick_button_add, amount)
            }

            Button(
                onClick = { onButtonClick(amount) },
                modifier = Modifier
                    .weight(1f)
                    .height(DS.Size.buttonHeight)
                    .semantics { contentDescription = buttonDescription },
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isSubtractMode) {
                        DS.Colors.error
                    } else {
                        DS.Colors.primary
                    }
                ),
                shape = RoundedCornerShape(DS.Size.cornerRadiusMedium)
            ) {
                Text(
                    text = "${if (isSubtractMode) "-" else "+"}${amount}ml",
                    style = MaterialTheme.typography.labelLarge,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
