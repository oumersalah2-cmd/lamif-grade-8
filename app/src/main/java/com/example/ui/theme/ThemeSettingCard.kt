package com.example.ui.theme

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Brightness4
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Material 3 Card allowing students to choose between Light, Dark,
 * and System theme modes with visual contrast feedback.
 */
@Composable
fun ThemeSettingCard(
  currentMode: AppThemeMode,
  onThemeModeSelected: (AppThemeMode) -> Unit,
  modifier: Modifier = Modifier
) {
  val isDark = when (currentMode) {
    AppThemeMode.SYSTEM -> isSystemInDarkTheme()
    AppThemeMode.LIGHT -> false
    AppThemeMode.DARK -> true
  }

  Card(
    shape = RoundedCornerShape(20.dp),
    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.6f)),
    modifier = modifier
      .fillMaxWidth()
      .testTag("theme_setting_card")
  ) {
    Column(modifier = Modifier.padding(18.dp)) {
      // Header: Icon, Title & Active Badge
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
          Surface(
            shape = CircleShape,
            color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.7f),
            modifier = Modifier.size(40.dp)
          ) {
            Box(contentAlignment = Alignment.Center) {
              Icon(
                imageVector = Icons.Default.Brightness4,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(22.dp)
              )
            }
          }

          Spacer(modifier = Modifier.width(12.dp))

          Column {
            Text(
              text = "Bifa Applikeshinii (Theme)",
              fontWeight = FontWeight.Bold,
              fontSize = 16.sp,
              color = MaterialTheme.colorScheme.onSurface
            )
            Text(
              text = "Light & Dark Mode (High Contrast)",
              fontSize = 11.5.sp,
              color = MaterialTheme.colorScheme.onSurfaceVariant
            )
          }
        }

        // Active Theme Pill
        Surface(
          shape = RoundedCornerShape(12.dp),
          color = MaterialTheme.colorScheme.primary.copy(alpha = 0.12f)
        ) {
          Text(
            text = if (isDark) "Dukkana" else "Ifaa",
            fontWeight = FontWeight.Bold,
            fontSize = 11.5.sp,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
          )
        }
      }

      Spacer(modifier = Modifier.height(14.dp))

      Text(
        text = "Bifa ifaa ykn dukkanaa filachuun qulqullina dubbisaa fi fayyummaa ija keetii eegi.",
        fontSize = 12.5.sp,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        lineHeight = 17.sp
      )

      Spacer(modifier = Modifier.height(16.dp))

      // 3-way Theme Selection Cards
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
      ) {
        AppThemeMode.entries.forEach { mode ->
          val isSelected = currentMode == mode
          val borderColor by animateColorAsState(
            if (isSelected) MaterialTheme.colorScheme.primary
            else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f),
            label = "border_anim"
          )
          val containerBg by animateColorAsState(
            if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.08f)
            else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.35f),
            label = "bg_anim"
          )

          Surface(
            shape = RoundedCornerShape(14.dp),
            color = containerBg,
            border = BorderStroke(if (isSelected) 2.dp else 1.dp, borderColor),
            modifier = Modifier
              .weight(1f)
              .clip(RoundedCornerShape(14.dp))
              .clickable { onThemeModeSelected(mode) }
              .testTag("theme_btn_${mode.name.lowercase()}")
          ) {
            Column(
              modifier = Modifier.padding(vertical = 12.dp, horizontal = 6.dp),
              horizontalAlignment = Alignment.CenterHorizontally
            ) {
              Box(
                modifier = Modifier
                  .size(32.dp)
                  .clip(CircleShape)
                  .background(
                    if (isSelected) MaterialTheme.colorScheme.primary
                    else MaterialTheme.colorScheme.surface
                  ),
                contentAlignment = Alignment.Center
              ) {
                Icon(
                  imageVector = mode.icon,
                  contentDescription = mode.titleOm,
                  tint = if (isSelected) MaterialTheme.colorScheme.onPrimary
                  else MaterialTheme.colorScheme.onSurfaceVariant,
                  modifier = Modifier.size(18.dp)
                )
              }

              Spacer(modifier = Modifier.height(6.dp))

              Text(
                text = mode.titleOm.split(" ").first(),
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                fontSize = 12.sp,
                color = if (isSelected) MaterialTheme.colorScheme.primary
                else MaterialTheme.colorScheme.onSurface
              )

              if (isSelected) {
                Spacer(modifier = Modifier.height(2.dp))
                Icon(
                  imageVector = Icons.Default.Check,
                  contentDescription = null,
                  tint = MaterialTheme.colorScheme.primary,
                  modifier = Modifier.size(12.dp)
                )
              }
            }
          }
        }
      }
    }
  }
}

/**
 * Compact TopAppBar Quick Toggle Button for instant switching between Light & Dark modes
 */
@Composable
fun ThemeQuickToggleButton(
  currentMode: AppThemeMode,
  onToggle: () -> Unit,
  modifier: Modifier = Modifier
) {
  val systemIsDark = isSystemInDarkTheme()
  val isDark = when (currentMode) {
    AppThemeMode.SYSTEM -> systemIsDark
    AppThemeMode.LIGHT -> false
    AppThemeMode.DARK -> true
  }

  IconButton(
    onClick = onToggle,
    modifier = modifier.testTag("quick_theme_toggle_btn")
  ) {
    Icon(
      imageVector = if (isDark) Icons.Default.LightMode else Icons.Default.DarkMode,
      contentDescription = if (isDark) "Bifa Ifaatti Jijjiiri" else "Bifa Dukkanaatti Jijjiiri",
      tint = MaterialTheme.colorScheme.primary
    )
  }
}
