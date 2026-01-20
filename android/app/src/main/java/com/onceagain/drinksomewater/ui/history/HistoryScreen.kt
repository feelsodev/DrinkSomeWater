package com.onceagain.drinksomewater.ui.history

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.outlined.Schedule
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.onceagain.drinksomewater.R
import com.onceagain.drinksomewater.core.domain.model.WaterRecord
import com.onceagain.drinksomewater.ui.theme.DS
import kotlinx.coroutines.launch

@Composable
fun HistoryScreen(
    viewModel: HistoryViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    HistoryContent(
        uiState = uiState,
        onEvent = viewModel::onEvent
    )
}

@Composable
private fun HistoryContent(
    uiState: HistoryUiState,
    onEvent: (HistoryEvent) -> Unit
) {
    val pagerState = rememberPagerState(
        initialPage = uiState.viewMode.ordinal,
        pageCount = { HistoryViewMode.entries.size }
    )
    val scope = rememberCoroutineScope()

    LaunchedEffect(pagerState.currentPage) {
        onEvent(HistoryEvent.ChangeViewMode(HistoryViewMode.entries[pagerState.currentPage]))
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        HeaderSection(
            successCount = uiState.currentMonthSuccessCount
        )

        ViewModeTabRow(
            selectedMode = uiState.viewMode,
            onModeSelected = { mode ->
                scope.launch {
                    pagerState.animateScrollToPage(mode.ordinal)
                }
            }
        )

        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            when (HistoryViewMode.entries[page]) {
                HistoryViewMode.CALENDAR -> CalendarTab(
                    records = uiState.records,
                    successDates = uiState.successDates,
                    selectedRecord = uiState.selectedRecord,
                    onDateSelected = { date -> onEvent(HistoryEvent.SelectDate(date)) }
                )
                HistoryViewMode.LIST -> ListTab(records = uiState.records)
                HistoryViewMode.TIMELINE -> TimelineTab(groupedRecords = uiState.groupedByMonth)
            }
        }
    }
}

@Composable
private fun HeaderSection(successCount: Int) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = DS.Spacing.md, vertical = DS.Spacing.md),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = stringResource(R.string.history_title),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )

        Card(
            colors = CardDefaults.cardColors(
                containerColor = DS.Colors.backgroundSecondary
            ),
            shape = RoundedCornerShape(DS.Size.cornerRadiusLarge)
        ) {
            Row(
                modifier = Modifier.padding(horizontal = DS.Spacing.sm, vertical = DS.Spacing.xs),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(text = stringResource(R.string.history_monthly_success))
                Spacer(modifier = Modifier.width(DS.Spacing.xs))
                Text(
                    text = "${successCount}${stringResource(R.string.unit_cups)}",
                    fontWeight = FontWeight.Bold,
                    color = DS.Colors.primary
                )
            }
        }
    }
}

@Composable
private fun ViewModeTabRow(
    selectedMode: HistoryViewMode,
    onModeSelected: (HistoryViewMode) -> Unit
) {
    TabRow(
        selectedTabIndex = selectedMode.ordinal,
        containerColor = MaterialTheme.colorScheme.background
    ) {
        HistoryViewMode.entries.forEach { mode ->
            Tab(
                selected = selectedMode == mode,
                onClick = { onModeSelected(mode) },
                text = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = mode.icon,
                            contentDescription = null,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(DS.Spacing.xxs))
                        Text(text = mode.label)
                    }
                }
            )
        }
    }
}

private val HistoryViewMode.icon: ImageVector
    get() = when (this) {
        HistoryViewMode.CALENDAR -> Icons.Default.DateRange
        HistoryViewMode.LIST -> Icons.Default.List
        HistoryViewMode.TIMELINE -> Icons.Outlined.Schedule
    }

private val HistoryViewMode.label: String
    @Composable get() = when (this) {
        HistoryViewMode.CALENDAR -> stringResource(R.string.history_calendar)
        HistoryViewMode.LIST -> stringResource(R.string.history_list)
        HistoryViewMode.TIMELINE -> stringResource(R.string.history_timeline)
    }

@Composable
private fun CalendarTab(
    records: List<WaterRecord>,
    successDates: List<String>,
    selectedRecord: WaterRecord?,
    onDateSelected: (kotlinx.datetime.LocalDate) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(DS.Spacing.md)
    ) {
        Text(
            text = "Calendar view - Coming soon",
            style = MaterialTheme.typography.bodyLarge,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )

        Spacer(modifier = Modifier.height(DS.Spacing.lg))

        selectedRecord?.let { record ->
            RecordCard(record = record)
        }
    }
}

@Composable
private fun ListTab(records: List<WaterRecord>) {
    if (records.isEmpty()) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = stringResource(R.string.history_no_records),
                style = MaterialTheme.typography.bodyLarge,
                color = DS.Colors.textSecondary
            )
        }
    } else {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = DS.Spacing.md),
            verticalArrangement = Arrangement.spacedBy(DS.Spacing.sm)
        ) {
            items(records, key = { it.id }) { record ->
                RecordListItem(record = record)
            }
        }
    }
}

@Composable
private fun RecordListItem(record: WaterRecord) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = DS.Colors.backgroundSecondary
        ),
        shape = RoundedCornerShape(DS.Size.cornerRadiusMedium)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(DS.Spacing.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = record.date.dayOfMonth.toString(),
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = if (record.isSuccess) DS.Colors.primary else DS.Colors.textSecondary
                )
                Text(
                    text = "${record.date.month.name.take(3)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = DS.Colors.textTertiary
                )
            }

            Spacer(modifier = Modifier.width(DS.Spacing.md))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = record.date.dayOfWeek.name.lowercase().replaceFirstChar { it.uppercase() },
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.SemiBold
                )

                Spacer(modifier = Modifier.height(DS.Spacing.xxs))

                LinearProgressIndicator(
                    progress = { record.progress },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(6.dp)
                        .clip(RoundedCornerShape(3.dp)),
                    color = if (record.isSuccess) DS.Colors.success else DS.Colors.primary,
                    trackColor = DS.Colors.backgroundTertiary
                )

                Spacer(modifier = Modifier.height(DS.Spacing.xxs))

                Text(
                    text = "${record.value}ml / ${record.goal}ml",
                    style = MaterialTheme.typography.bodySmall,
                    color = DS.Colors.textTertiary
                )
            }

            Spacer(modifier = Modifier.width(DS.Spacing.md))

            if (record.isSuccess) {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = null,
                    tint = DS.Colors.success,
                    modifier = Modifier.size(24.dp)
                )
            } else {
                Text(
                    text = "${record.progressPercent}%",
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold,
                    color = DS.Colors.textSecondary
                )
            }
        }
    }
}

@Composable
private fun TimelineTab(groupedRecords: Map<String, List<WaterRecord>>) {
    if (groupedRecords.isEmpty()) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = stringResource(R.string.history_no_records),
                style = MaterialTheme.typography.bodyLarge,
                color = DS.Colors.textSecondary
            )
        }
    } else {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = DS.Spacing.md)
        ) {
            groupedRecords.entries.sortedByDescending { it.key }.forEach { (month, records) ->
                item(key = month) {
                    TimelineMonthSection(
                        month = month,
                        records = records.sortedByDescending { it.date }
                    )
                }
            }
        }
    }
}

@Composable
private fun TimelineMonthSection(
    month: String,
    records: List<WaterRecord>
) {
    val successCount = records.count { it.isSuccess }

    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = DS.Spacing.sm),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = month,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "$successCount / ${records.size}",
                style = MaterialTheme.typography.bodyMedium,
                color = DS.Colors.textSecondary
            )
        }

        records.forEachIndexed { index, record ->
            TimelineRecordItem(
                record = record,
                isLast = index == records.lastIndex
            )
        }
    }
}

@Composable
private fun TimelineRecordItem(
    record: WaterRecord,
    isLast: Boolean
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(DS.Spacing.md)
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(DS.Spacing.sm)
                    .clip(CircleShape)
                    .background(
                        if (record.isSuccess) DS.Colors.success
                        else DS.Colors.primary.copy(alpha = 0.3f)
                    )
            )
            if (!isLast) {
                Box(
                    modifier = Modifier
                        .width(2.dp)
                        .height(DS.Spacing.xxl)
                        .background(DS.Colors.primary.copy(alpha = 0.2f))
                )
            }
        }

        Column(
            modifier = Modifier.padding(bottom = if (isLast) DS.Spacing.none else DS.Spacing.lg)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "${record.date.month.name.take(3)} ${record.date.dayOfMonth}",
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.SemiBold
                )
                if (record.isSuccess) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = DS.Colors.success,
                            modifier = Modifier.size(14.dp)
                        )
                        Spacer(modifier = Modifier.width(DS.Spacing.xxs))
                        Text(
                            text = "Achieved",
                            style = MaterialTheme.typography.labelSmall,
                            color = DS.Colors.success
                        )
                    }
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(DS.Spacing.md)) {
                Text(
                    text = "${record.value}ml",
                    style = MaterialTheme.typography.bodySmall,
                    color = DS.Colors.primary
                )
                Text(
                    text = "Goal: ${record.goal}ml",
                    style = MaterialTheme.typography.bodySmall,
                    color = DS.Colors.textTertiary
                )
            }
        }
    }
}

@Composable
private fun RecordCard(record: WaterRecord) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = DS.Colors.backgroundSecondary
        ),
        shape = RoundedCornerShape(DS.Size.cornerRadiusLarge)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(DS.Spacing.lg),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "${record.date.month.name.take(3)} ${record.date.dayOfMonth}",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(DS.Spacing.xs))
                Row(horizontalArrangement = Arrangement.spacedBy(DS.Spacing.md)) {
                    Column {
                        Text(
                            text = "Goal",
                            style = MaterialTheme.typography.labelSmall,
                            color = DS.Colors.textTertiary
                        )
                        Text(
                            text = "${record.goal}ml",
                            style = MaterialTheme.typography.bodyMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                    Column {
                        Text(
                            text = "Intake",
                            style = MaterialTheme.typography.labelSmall,
                            color = DS.Colors.textTertiary
                        )
                        Text(
                            text = "${record.value}ml",
                            style = MaterialTheme.typography.bodyMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "${record.progressPercent}%",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = if (record.isSuccess) DS.Colors.success else DS.Colors.primary
                )
                if (record.isSuccess) {
                    Text(
                        text = "Achieved",
                        style = MaterialTheme.typography.labelSmall,
                        color = DS.Colors.success,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}
