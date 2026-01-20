package com.onceagain.drinksomewater.ui.onboarding

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Widgets
import androidx.compose.material.icons.outlined.WaterDrop
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.onceagain.drinksomewater.ui.theme.DS
import kotlinx.coroutines.launch

@Composable
fun OnboardingScreen(
    viewModel: OnboardingViewModel = hiltViewModel(),
    onComplete: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(uiState.isCompleted) {
        if (uiState.isCompleted) {
            onComplete()
        }
    }

    OnboardingContent(
        uiState = uiState,
        onEvent = viewModel::onEvent
    )
}

@Composable
private fun OnboardingContent(
    uiState: OnboardingUiState,
    onEvent: (OnboardingEvent) -> Unit
) {
    val pagerState = rememberPagerState(
        initialPage = uiState.currentPage,
        pageCount = { uiState.totalPages }
    )
    val scope = rememberCoroutineScope()

    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.currentPage }.collect { page ->
            if (page != uiState.currentPage) {
                onEvent(OnboardingEvent.GoToPage(page))
            }
        }
    }

    LaunchedEffect(uiState.currentPage) {
        if (pagerState.currentPage != uiState.currentPage) {
            pagerState.animateScrollToPage(uiState.currentPage)
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        DS.Colors.backgroundPrimary,
                        DS.Colors.primaryLight.copy(alpha = 0.15f),
                        DS.Colors.backgroundPrimary
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier.fillMaxSize()
        ) {
            HorizontalPager(
                state = pagerState,
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) { page ->
                when (page) {
                    0 -> IntroPage()
                    1 -> GoalSettingPage(
                        currentGoal = uiState.goalMl,
                        onGoalChange = { onEvent(OnboardingEvent.UpdateGoal(it)) }
                    )
                    2 -> HealthConnectPage()
                    3 -> NotificationPage()
                    4 -> WidgetGuidePage()
                }
            }

            BottomSection(
                currentPage = pagerState.currentPage,
                totalPages = uiState.totalPages,
                isLastPage = pagerState.currentPage == uiState.totalPages - 1,
                onSkip = { onEvent(OnboardingEvent.CompleteOnboarding) },
                onNext = {
                    if (pagerState.currentPage < uiState.totalPages - 1) {
                        scope.launch {
                            pagerState.animateScrollToPage(pagerState.currentPage + 1)
                        }
                    }
                },
                onStart = { onEvent(OnboardingEvent.CompleteOnboarding) }
            )
        }
    }
}

@Composable
private fun IntroPage() {
    OnboardingPageLayout(
        icon = Icons.Outlined.WaterDrop,
        iconTint = DS.Colors.primary,
        title = "벌컥벌컥",
        subtitle = "물 마시기 습관을\n쉽고 즐겁게 시작하세요",
        description = "매일 목표를 정하고\n얼마나 마셨는지 기록해보세요"
    )
}

@Composable
private fun GoalSettingPage(
    currentGoal: Int,
    onGoalChange: (Int) -> Unit
) {
    var sliderValue by remember(currentGoal) { mutableFloatStateOf(currentGoal.toFloat()) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = DS.Spacing.xl),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(120.dp)
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            DS.Colors.primary.copy(alpha = 0.2f),
                            DS.Colors.primary.copy(alpha = 0.05f)
                        )
                    )
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Outlined.WaterDrop,
                contentDescription = null,
                tint = DS.Colors.primary,
                modifier = Modifier.size(56.dp)
            )
        }

        Spacer(modifier = Modifier.height(DS.Spacing.xxl))

        Text(
            text = "목표 설정",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.textPrimary
        )

        Spacer(modifier = Modifier.height(DS.Spacing.sm))

        Text(
            text = "하루에 마실 물의 양을 설정하세요",
            style = MaterialTheme.typography.bodyLarge,
            color = DS.Colors.textSecondary,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(DS.Spacing.xxxl))

        Text(
            text = "${sliderValue.toInt()}ml",
            style = MaterialTheme.typography.displayMedium.copy(
                fontSize = 48.sp
            ),
            fontWeight = FontWeight.Bold,
            color = DS.Colors.primary
        )

        Spacer(modifier = Modifier.height(DS.Spacing.lg))

        Slider(
            value = sliderValue,
            onValueChange = { sliderValue = it },
            onValueChangeFinished = { onGoalChange(sliderValue.toInt()) },
            valueRange = OnboardingViewModel.MIN_GOAL.toFloat()..OnboardingViewModel.MAX_GOAL.toFloat(),
            steps = ((OnboardingViewModel.MAX_GOAL - OnboardingViewModel.MIN_GOAL) / 100) - 1,
            colors = SliderDefaults.colors(
                thumbColor = DS.Colors.primary,
                activeTrackColor = DS.Colors.primary,
                inactiveTrackColor = DS.Colors.primaryLight.copy(alpha = 0.3f)
            ),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(DS.Spacing.xs))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "${OnboardingViewModel.MIN_GOAL}ml",
                style = MaterialTheme.typography.bodySmall,
                color = DS.Colors.textTertiary
            )
            Text(
                text = "${OnboardingViewModel.MAX_GOAL}ml",
                style = MaterialTheme.typography.bodySmall,
                color = DS.Colors.textTertiary
            )
        }

        Spacer(modifier = Modifier.height(DS.Spacing.lg))

        Text(
            text = "권장량: 체중(kg) × 33ml",
            style = MaterialTheme.typography.bodySmall,
            color = DS.Colors.textTertiary
        )
    }
}

@Composable
private fun HealthConnectPage() {
    OnboardingPageLayout(
        icon = Icons.Default.Favorite,
        iconTint = Color(0xFFE91E63),
        title = "건강 연동",
        subtitle = "Health Connect와\n연동할 수 있어요",
        description = "다른 건강 앱들과 데이터를 공유하고\n더 정확한 건강 관리를 해보세요"
    )
}

@Composable
private fun NotificationPage() {
    OnboardingPageLayout(
        icon = Icons.Default.Notifications,
        iconTint = DS.Colors.warning,
        title = "알림 설정",
        subtitle = "물 마실 시간을\n알려드릴게요",
        description = "잊지 않고 물을 마실 수 있도록\n설정한 시간마다 알림을 보내드려요"
    )
}

@Composable
private fun WidgetGuidePage() {
    OnboardingPageLayout(
        icon = Icons.Default.Widgets,
        iconTint = DS.Colors.primary,
        title = "위젯 추가",
        subtitle = "홈 화면에서\n바로 기록하세요",
        description = "위젯을 추가하면 앱을 열지 않고도\n물 섭취량을 기록할 수 있어요"
    )
}

@Composable
private fun OnboardingPageLayout(
    icon: ImageVector,
    iconTint: Color,
    title: String,
    subtitle: String,
    description: String
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = DS.Spacing.xl),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(120.dp)
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            iconTint.copy(alpha = 0.2f),
                            iconTint.copy(alpha = 0.05f)
                        )
                    )
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconTint,
                modifier = Modifier.size(56.dp)
            )
        }

        Spacer(modifier = Modifier.height(DS.Spacing.xxl))

        Text(
            text = title,
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = DS.Colors.textPrimary
        )

        Spacer(modifier = Modifier.height(DS.Spacing.md))

        Text(
            text = subtitle,
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Medium,
            color = DS.Colors.textPrimary,
            textAlign = TextAlign.Center,
            lineHeight = 36.sp
        )

        Spacer(modifier = Modifier.height(DS.Spacing.lg))

        Text(
            text = description,
            style = MaterialTheme.typography.bodyLarge,
            color = DS.Colors.textSecondary,
            textAlign = TextAlign.Center,
            lineHeight = 26.sp
        )
    }
}

@Composable
private fun BottomSection(
    currentPage: Int,
    totalPages: Int,
    isLastPage: Boolean,
    onSkip: () -> Unit,
    onNext: () -> Unit,
    onStart: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(DS.Spacing.xl)
    ) {
        PageIndicator(
            currentPage = currentPage,
            totalPages = totalPages,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )

        Spacer(modifier = Modifier.height(DS.Spacing.xxl))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (!isLastPage) {
                TextButton(
                    onClick = onSkip,
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = DS.Colors.textSecondary
                    )
                ) {
                    Text(
                        text = "건너뛰기",
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Medium
                    )
                }
            } else {
                Spacer(modifier = Modifier.width(1.dp))
            }

            Button(
                onClick = if (isLastPage) onStart else onNext,
                colors = ButtonDefaults.buttonColors(
                    containerColor = DS.Colors.primary
                ),
                shape = RoundedCornerShape(DS.Size.cornerRadiusMedium),
                modifier = Modifier
                    .height(DS.Size.buttonHeight)
                    .then(
                        if (isLastPage) Modifier.fillMaxWidth(0.8f) else Modifier
                    )
            ) {
                Text(
                    text = if (isLastPage) "시작하기" else "다음",
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        Spacer(modifier = Modifier.height(DS.Spacing.lg))
    }
}

@Composable
private fun PageIndicator(
    currentPage: Int,
    totalPages: Int,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(DS.Spacing.xs)
    ) {
        repeat(totalPages) { index ->
            val isSelected = index == currentPage

            val width by animateDpAsState(
                targetValue = if (isSelected) 24.dp else 8.dp,
                animationSpec = tween(durationMillis = 300),
                label = "indicator_width"
            )

            val color by animateColorAsState(
                targetValue = if (isSelected) DS.Colors.primary else DS.Colors.primaryLight.copy(alpha = 0.4f),
                animationSpec = tween(durationMillis = 300),
                label = "indicator_color"
            )

            Box(
                modifier = Modifier
                    .height(8.dp)
                    .width(width)
                    .clip(RoundedCornerShape(4.dp))
                    .background(color)
            )
        }
    }
}
