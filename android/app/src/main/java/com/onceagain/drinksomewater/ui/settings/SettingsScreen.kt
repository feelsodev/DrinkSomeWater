package com.onceagain.drinksomewater.ui.settings

import android.content.Intent
import android.net.Uri
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.MenuBook
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.TrackChanges
import androidx.compose.material.icons.filled.Widgets
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.onceagain.drinksomewater.R
import com.onceagain.drinksomewater.core.domain.model.UserProfile
import com.onceagain.drinksomewater.ui.components.WaveAnimation
import com.onceagain.drinksomewater.ui.theme.DS
import kotlinx.coroutines.launch

@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    
    SettingsContent(
        uiState = uiState,
        onEvent = viewModel::onEvent
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SettingsContent(
    uiState: SettingsUiState,
    onEvent: (SettingsEvent) -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    
    var showGoalSheet by remember { mutableStateOf(false) }
    var showQuickButtonSheet by remember { mutableStateOf(false) }
    var showProfileSheet by remember { mutableStateOf(false) }
    var showNotificationSheet by remember { mutableStateOf(false) }
    
    val goalSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val quickButtonSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val profileSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val notificationSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    Box(modifier = Modifier.fillMaxSize()) {
        WaveAnimation(
            progress = 0.5f,
            isGoalAchieved = false,
            modifier = Modifier.fillMaxSize()
        )
        
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = DS.Spacing.md)
        ) {
            item {
                Spacer(modifier = Modifier.height(DS.Spacing.xl))
                
                Text(
                    text = stringResource(R.string.settings_title),
                    style = MaterialTheme.typography.headlineLarge,
                    fontWeight = FontWeight.Bold,
                    color = DS.Colors.textPrimary
                )
                
                Spacer(modifier = Modifier.height(DS.Spacing.xxs))
                
                Text(
                    text = "나만의 설정을 해보세요",
                    style = MaterialTheme.typography.bodyMedium,
                    color = DS.Colors.textSecondary
                )
                
                Spacer(modifier = Modifier.height(DS.Spacing.xl))
            }
            
            item {
                SettingsSectionHeader(title = "개인 설정")
                
                SettingsCard {
                    SettingsItem(
                        icon = Icons.Default.Person,
                        iconTint = DS.Colors.primary,
                        title = "프로필",
                        subtitle = null,
                        onClick = { showProfileSheet = true }
                    )
                    
                    SettingsDivider()
                    
                    SettingsItem(
                        icon = Icons.Default.TrackChanges,
                        iconTint = DS.Colors.success,
                        title = stringResource(R.string.settings_goal),
                        subtitle = uiState.goalFormatted,
                        onClick = { showGoalSheet = true }
                    )
                    
                    SettingsDivider()
                    
                    SettingsItem(
                        icon = Icons.Default.Bolt,
                        iconTint = DS.Colors.warning,
                        title = stringResource(R.string.settings_quick_buttons),
                        subtitle = uiState.quickButtonsFormatted,
                        onClick = { showQuickButtonSheet = true }
                    )
                }
                
                Spacer(modifier = Modifier.height(DS.Spacing.lg))
            }
            
            item {
                SettingsSectionHeader(title = "앱 설정")
                
                SettingsCard {
                    SettingsItem(
                        icon = Icons.Default.Notifications,
                        iconTint = DS.Colors.error,
                        title = stringResource(R.string.settings_notifications),
                        subtitle = if (uiState.notificationEnabled) "켜짐" else "꺼짐",
                        onClick = { showNotificationSheet = true }
                    )
                    
                    SettingsDivider()
                    
                    SettingsItem(
                        icon = Icons.Default.Widgets,
                        iconTint = DS.Colors.primary,
                        title = stringResource(R.string.settings_widget_guide),
                        subtitle = null,
                        onClick = { }
                    )
                    
                    SettingsDivider()
                    
                    SettingsItem(
                        icon = Icons.Default.MenuBook,
                        iconTint = DS.Colors.textSecondary,
                        title = "앱 가이드",
                        subtitle = null,
                        onClick = { }
                    )
                }
                
                Spacer(modifier = Modifier.height(DS.Spacing.lg))
            }
            
            item {
                SettingsSectionHeader(title = "지원")
                
                SettingsCard {
                    SettingsItem(
                        icon = Icons.Default.Favorite,
                        iconTint = Color(0xFFE91E63),
                        title = "개발자 응원하기",
                        subtitle = null,
                        onClick = { }
                    )
                    
                    SettingsDivider()
                    
                    SettingsItem(
                        icon = Icons.Default.Star,
                        iconTint = Color(0xFFFFB300),
                        title = stringResource(R.string.settings_review),
                        subtitle = null,
                        onClick = {
                            val intent = Intent(
                                Intent.ACTION_VIEW,
                                Uri.parse("market://details?id=${context.packageName}")
                            )
                            context.startActivity(intent)
                        }
                    )
                    
                    SettingsDivider()
                    
                    SettingsItem(
                        icon = Icons.Default.Email,
                        iconTint = DS.Colors.primary,
                        title = stringResource(R.string.settings_contact),
                        subtitle = null,
                        onClick = {
                            val intent = Intent(Intent.ACTION_SENDTO).apply {
                                data = Uri.parse("mailto:feelso.dev@gmail.com")
                                putExtra(Intent.EXTRA_SUBJECT, "[벌컥벌컥] 문의")
                            }
                            context.startActivity(intent)
                        }
                    )
                }
                
                Spacer(modifier = Modifier.height(DS.Spacing.lg))
            }
            
            item {
                SettingsSectionHeader(title = "정보")
                
                SettingsCard {
                    SettingsItem(
                        icon = Icons.Default.Info,
                        iconTint = DS.Colors.textTertiary,
                        title = stringResource(R.string.settings_version),
                        subtitle = uiState.appVersion,
                        showArrow = false,
                        onClick = { }
                    )
                }
                
                Spacer(modifier = Modifier.height(DS.Spacing.xxxl))
            }
        }
    }
    
    if (showGoalSheet) {
        ModalBottomSheet(
            onDismissRequest = { showGoalSheet = false },
            sheetState = goalSheetState,
            containerColor = DS.Colors.backgroundSecondary
        ) {
            GoalSettingContent(
                currentGoal = uiState.goalMl,
                recommendedGoal = uiState.recommendedIntakeMl,
                onGoalChange = { goal ->
                    onEvent(SettingsEvent.UpdateGoal(goal))
                },
                onDismiss = {
                    scope.launch {
                        goalSheetState.hide()
                        showGoalSheet = false
                    }
                }
            )
        }
    }
    
    if (showQuickButtonSheet) {
        ModalBottomSheet(
            onDismissRequest = { showQuickButtonSheet = false },
            sheetState = quickButtonSheetState,
            containerColor = DS.Colors.backgroundSecondary
        ) {
            QuickButtonSettingContent(
                quickButtons = uiState.quickButtons,
                onQuickButtonChange = { index, value ->
                    onEvent(SettingsEvent.UpdateQuickButton(index, value))
                },
                onDismiss = {
                    scope.launch {
                        quickButtonSheetState.hide()
                        showQuickButtonSheet = false
                    }
                }
            )
        }
    }
    
    if (showProfileSheet) {
        ModalBottomSheet(
            onDismissRequest = { showProfileSheet = false },
            sheetState = profileSheetState,
            containerColor = DS.Colors.backgroundSecondary
        ) {
            ProfileSettingContent(
                weightKg = uiState.weightKg,
                useHealthConnect = uiState.useHealthConnect,
                onWeightChange = { weight ->
                    onEvent(SettingsEvent.UpdateWeight(weight))
                },
                onHealthConnectToggle = {
                    onEvent(SettingsEvent.ToggleHealthConnect)
                },
                onDismiss = {
                    scope.launch {
                        profileSheetState.hide()
                        showProfileSheet = false
                    }
                }
            )
        }
    }
    
    if (showNotificationSheet) {
        ModalBottomSheet(
            onDismissRequest = { showNotificationSheet = false },
            sheetState = notificationSheetState,
            containerColor = DS.Colors.backgroundSecondary
        ) {
            NotificationSettingContent(
                enabled = uiState.notificationEnabled,
                interval = uiState.notificationInterval,
                startHour = uiState.notificationStartHour,
                endHour = uiState.notificationEndHour,
                onToggle = { onEvent(SettingsEvent.ToggleNotification) },
                onIntervalChange = { onEvent(SettingsEvent.UpdateNotificationInterval(it)) },
                onTimeChange = { start, end ->
                    onEvent(SettingsEvent.UpdateNotificationTime(start, end))
                },
                onDismiss = {
                    scope.launch {
                        notificationSheetState.hide()
                        showNotificationSheet = false
                    }
                }
            )
        }
    }
}

@Composable
private fun SettingsSectionHeader(title: String) {
    Text(
        text = title.uppercase(),
        style = MaterialTheme.typography.labelMedium,
        fontWeight = FontWeight.SemiBold,
        color = DS.Colors.textSecondary,
        modifier = Modifier.padding(start = DS.Spacing.sm, bottom = DS.Spacing.xs)
    )
}

@Composable
private fun SettingsCard(
    content: @Composable () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(DS.Size.cornerRadiusMedium),
        colors = CardDefaults.cardColors(
            containerColor = DS.Colors.backgroundSecondary
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Column(modifier = Modifier.padding(vertical = DS.Spacing.xs)) {
            content()
        }
    }
}

@Composable
private fun SettingsItem(
    icon: ImageVector,
    iconTint: Color,
    title: String,
    subtitle: String?,
    showArrow: Boolean = true,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = DS.Spacing.md, vertical = DS.Spacing.sm),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(iconTint.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconTint,
                modifier = Modifier.size(20.dp)
            )
        }
        
        Spacer(modifier = Modifier.width(DS.Spacing.sm))
        
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge,
                color = DS.Colors.textPrimary
            )
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = DS.Colors.textSecondary
                )
            }
        }
        
        if (showArrow) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = DS.Colors.textTertiary
            )
        }
    }
}

@Composable
private fun SettingsDivider() {
    HorizontalDivider(
        modifier = Modifier.padding(start = 60.dp),
        color = DS.Colors.divider,
        thickness = 0.5.dp
    )
}

@Composable
private fun GoalSettingContent(
    currentGoal: Int,
    recommendedGoal: Int,
    onGoalChange: (Int) -> Unit,
    onDismiss: () -> Unit
) {
    var sliderValue by remember { mutableFloatStateOf(currentGoal.toFloat()) }
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(DS.Spacing.xl)
    ) {
        Text(
            text = stringResource(R.string.goal_setting_title),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.textPrimary
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xs))
        
        Text(
            text = stringResource(R.string.goal_setting_description),
            style = MaterialTheme.typography.bodyMedium,
            color = DS.Colors.textSecondary
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxl))
        
        Text(
            text = "${sliderValue.toInt()}ml",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.primary,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.md))
        
        Slider(
            value = sliderValue,
            onValueChange = { sliderValue = it },
            onValueChangeFinished = { onGoalChange(sliderValue.toInt()) },
            valueRange = UserProfile.MIN_GOAL_ML.toFloat()..UserProfile.MAX_GOAL_ML.toFloat(),
            steps = ((UserProfile.MAX_GOAL_ML - UserProfile.MIN_GOAL_ML) / 100) - 1,
            colors = SliderDefaults.colors(
                thumbColor = DS.Colors.primary,
                activeTrackColor = DS.Colors.primary,
                inactiveTrackColor = DS.Colors.primaryLight.copy(alpha = 0.3f)
            )
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xs))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "${UserProfile.MIN_GOAL_ML}ml",
                style = MaterialTheme.typography.bodySmall,
                color = DS.Colors.textTertiary
            )
            Text(
                text = "${UserProfile.MAX_GOAL_ML}ml",
                style = MaterialTheme.typography.bodySmall,
                color = DS.Colors.textTertiary
            )
        }
        
        Spacer(modifier = Modifier.height(DS.Spacing.md))
        
        Text(
            text = stringResource(R.string.goal_setting_recommended, recommendedGoal),
            style = MaterialTheme.typography.bodySmall,
            color = DS.Colors.textSecondary,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxxl))
    }
}

@Composable
private fun QuickButtonSettingContent(
    quickButtons: List<Int>,
    onQuickButtonChange: (Int, Int) -> Unit,
    onDismiss: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(DS.Spacing.xl)
    ) {
        Text(
            text = stringResource(R.string.quick_button_setting_title),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.textPrimary
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xs))
        
        Text(
            text = stringResource(R.string.quick_button_setting_description),
            style = MaterialTheme.typography.bodyMedium,
            color = DS.Colors.textSecondary
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxl))
        
        quickButtons.forEachIndexed { index, value ->
            QuickButtonSlider(
                index = index + 1,
                value = value,
                onValueChange = { onQuickButtonChange(index, it) }
            )
            
            if (index < quickButtons.lastIndex) {
                Spacer(modifier = Modifier.height(DS.Spacing.md))
            }
        }
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxxl))
    }
}

@Composable
private fun QuickButtonSlider(
    index: Int,
    value: Int,
    onValueChange: (Int) -> Unit
) {
    var sliderValue by remember(value) { mutableFloatStateOf(value.toFloat()) }
    
    Column {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "버튼 $index",
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = DS.Colors.textPrimary
            )
            Text(
                text = "${sliderValue.toInt()}ml",
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold,
                color = DS.Colors.primary
            )
        }
        
        Spacer(modifier = Modifier.height(DS.Spacing.xs))
        
        Slider(
            value = sliderValue,
            onValueChange = { sliderValue = it },
            onValueChangeFinished = { onValueChange(sliderValue.toInt()) },
            valueRange = 50f..1000f,
            steps = 18,
            colors = SliderDefaults.colors(
                thumbColor = DS.Colors.primary,
                activeTrackColor = DS.Colors.primary,
                inactiveTrackColor = DS.Colors.primaryLight.copy(alpha = 0.3f)
            )
        )
    }
}

@Composable
private fun ProfileSettingContent(
    weightKg: Float,
    useHealthConnect: Boolean,
    onWeightChange: (Float) -> Unit,
    onHealthConnectToggle: () -> Unit,
    onDismiss: () -> Unit
) {
    var sliderValue by remember { mutableFloatStateOf(weightKg) }
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(DS.Spacing.xl)
    ) {
        Text(
            text = "프로필 설정",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.textPrimary
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxl))
        
        Text(
            text = "체중",
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium,
            color = DS.Colors.textPrimary
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xs))
        
        Text(
            text = "${sliderValue.toInt()}kg",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.primary,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.md))
        
        Slider(
            value = sliderValue,
            onValueChange = { sliderValue = it },
            onValueChangeFinished = { onWeightChange(sliderValue) },
            valueRange = 30f..150f,
            steps = 119,
            colors = SliderDefaults.colors(
                thumbColor = DS.Colors.primary,
                activeTrackColor = DS.Colors.primary,
                inactiveTrackColor = DS.Colors.primaryLight.copy(alpha = 0.3f)
            )
        )
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "30kg",
                style = MaterialTheme.typography.bodySmall,
                color = DS.Colors.textTertiary
            )
            Text(
                text = "150kg",
                style = MaterialTheme.typography.bodySmall,
                color = DS.Colors.textTertiary
            )
        }
        
        Spacer(modifier = Modifier.height(DS.Spacing.md))
        
        val recommendedIntake = (sliderValue * 33).toInt()
        Text(
            text = "권장 물 섭취량: ${recommendedIntake}ml",
            style = MaterialTheme.typography.bodySmall,
            color = DS.Colors.textSecondary,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxxl))
    }
}

@Composable
private fun NotificationSettingContent(
    enabled: Boolean,
    interval: Int,
    startHour: Int,
    endHour: Int,
    onToggle: () -> Unit,
    onIntervalChange: (Int) -> Unit,
    onTimeChange: (Int, Int) -> Unit,
    onDismiss: () -> Unit
) {
    var intervalValue by remember { mutableFloatStateOf(interval.toFloat()) }
    var startValue by remember { mutableFloatStateOf(startHour.toFloat()) }
    var endValue by remember { mutableFloatStateOf(endHour.toFloat()) }
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(DS.Spacing.xl)
    ) {
        Text(
            text = stringResource(R.string.settings_notifications),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.textPrimary
        )
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxl))
        
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(onClick = onToggle)
                .padding(vertical = DS.Spacing.sm),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = stringResource(R.string.notification_enable),
                style = MaterialTheme.typography.bodyLarge,
                color = DS.Colors.textPrimary
            )
            
            Box(
                modifier = Modifier
                    .size(width = 50.dp, height = 28.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(if (enabled) DS.Colors.primary else DS.Colors.textTertiary)
                    .padding(2.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .align(if (enabled) Alignment.CenterEnd else Alignment.CenterStart)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White)
                )
            }
        }
        
        if (enabled) {
            Spacer(modifier = Modifier.height(DS.Spacing.xl))
            
            Text(
                text = stringResource(R.string.notification_interval),
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = DS.Colors.textPrimary
            )
            
            Text(
                text = "${intervalValue.toInt()}분마다",
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold,
                color = DS.Colors.primary
            )
            
            Slider(
                value = intervalValue,
                onValueChange = { intervalValue = it },
                onValueChangeFinished = { onIntervalChange(intervalValue.toInt()) },
                valueRange = 30f..180f,
                steps = 4,
                colors = SliderDefaults.colors(
                    thumbColor = DS.Colors.primary,
                    activeTrackColor = DS.Colors.primary
                )
            )
            
            Spacer(modifier = Modifier.height(DS.Spacing.lg))
            
            Text(
                text = stringResource(R.string.notification_start_time),
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = DS.Colors.textPrimary
            )
            
            Text(
                text = "${startValue.toInt()}시",
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold,
                color = DS.Colors.primary
            )
            
            Slider(
                value = startValue,
                onValueChange = { startValue = it },
                onValueChangeFinished = { onTimeChange(startValue.toInt(), endValue.toInt()) },
                valueRange = 6f..12f,
                steps = 5,
                colors = SliderDefaults.colors(
                    thumbColor = DS.Colors.primary,
                    activeTrackColor = DS.Colors.primary
                )
            )
            
            Spacer(modifier = Modifier.height(DS.Spacing.lg))
            
            Text(
                text = stringResource(R.string.notification_end_time),
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = DS.Colors.textPrimary
            )
            
            Text(
                text = "${endValue.toInt()}시",
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold,
                color = DS.Colors.primary
            )
            
            Slider(
                value = endValue,
                onValueChange = { endValue = it },
                onValueChangeFinished = { onTimeChange(startValue.toInt(), endValue.toInt()) },
                valueRange = 18f..24f,
                steps = 5,
                colors = SliderDefaults.colors(
                    thumbColor = DS.Colors.primary,
                    activeTrackColor = DS.Colors.primary
                )
            )
        }
        
        Spacer(modifier = Modifier.height(DS.Spacing.xxxl))
    }
}
