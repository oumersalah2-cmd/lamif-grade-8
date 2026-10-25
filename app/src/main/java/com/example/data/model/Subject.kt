package com.example.data.model

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoStories
import androidx.compose.material.icons.filled.Calculate
import androidx.compose.material.icons.filled.Gavel
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.Public
import androidx.compose.material.icons.filled.Science
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector

enum class Subject(
  val id: String,
  val afaanOromoName: String,
  val englishName: String,
  val descriptionOm: String,
  val defaultMinutes: Int,
  val icon: ImageVector,
  val accentColor: Color
) {
  AFAAN_OROMOO(
    id = "afaan_oromoo",
    afaanOromoName = "Afaan Oromoo",
    englishName = "Afaan Oromoo",
    descriptionOm = "Caasluga, Dhamsuu, Mamaksa fi Og-barruu",
    defaultMinutes = 45,
    icon = Icons.Default.AutoStories,
    accentColor = Color(0xFF16A34A)
  ),
  HERREGA(
    id = "herrega",
    afaanOromoName = "Herrega",
    englishName = "Mathematics",
    descriptionOm = "Lakkofsa, Aljebraa, Ji'oomeetirii fi Pisii",
    defaultMinutes = 60,
    icon = Icons.Default.Calculate,
    accentColor = Color(0xFF2563EB)
  ),
  SAAYINSII_WALIIGALAA(
    id = "saayinsii_waliigalaa",
    afaanOromoName = "Saayinsii Waliigalaa",
    englishName = "General Science",
    descriptionOm = "Baayoloojii, Fiiziksii fi Keemistirii",
    defaultMinutes = 50,
    icon = Icons.Default.Science,
    accentColor = Color(0xFF7C3AED)
  ),
  SAAYINSII_HAWAASAA(
    id = "saayinsii_hawaasaa",
    afaanOromoName = "Saayinsii Hawaasaa",
    englishName = "Social Studies",
    descriptionOm = "Seenaa, Ji'oogiraafii fi Hawaasummaa",
    defaultMinutes = 45,
    icon = Icons.Default.Public,
    accentColor = Color(0xFFEA580C)
  ),
  LAMMUMMAA(
    id = "lammummaa",
    afaanOromoName = "Barnoota Lammummaa",
    englishName = "Citizenship",
    descriptionOm = "Heera, Dimokraasii, Mirga fi Dirqama",
    defaultMinutes = 40,
    icon = Icons.Default.Gavel,
    accentColor = Color(0xFF0D9488)
  ),
  ENGLISH(
    id = "english",
    afaanOromoName = "Afaan Ingilizii",
    englishName = "English Language",
    descriptionOm = "Grammar, Vocabulary & Comprehension",
    defaultMinutes = 45,
    icon = Icons.Default.Language,
    accentColor = Color(0xFFD97706)
  );

  companion object {
    fun fromId(id: String): Subject {
      return entries.find { it.id.equals(id, ignoreCase = true) } ?: AFAAN_OROMOO
    }
  }
}
