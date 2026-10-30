package com.example.features.activation

import android.app.Application
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.core.crypto.ActivationResult
import com.example.core.crypto.ActivationSecurityManager
import com.example.data.local.AppDatabase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class ActivationUiState(
  val deviceId: String = "",
  val inputCode: String = "",
  val isActivated: Boolean = false,
  val plan: String = "NONE",
  val expiryFormatted: String? = null,
  val isLoading: Boolean = false,
  val errorMessage: String? = null,
  val successMessage: String? = null
)

class ActivationViewModel(application: Application) : AndroidViewModel(application) {
  private val securityManager = ActivationSecurityManager(application)
  private val database = AppDatabase.getDatabase(application)

  private val _uiState = MutableStateFlow(ActivationUiState())
  val uiState: StateFlow<ActivationUiState> = _uiState.asStateFlow()

  init {
    loadActivationStatus()
  }

  fun loadActivationStatus() {
    val deviceId = securityManager.getOrCreateDeviceId()
    viewModelScope.launch {
      val entity = database.activationDao().getActivation()
      val isAct = securityManager.isCurrentlyActivated()
      val expString = entity?.expiryTimestamp?.let { formatExpiry(it) }

      _uiState.update {
        it.copy(
          deviceId = deviceId,
          isActivated = isAct,
          plan = if (isAct) entity?.plan ?: "LIFETIME" else "NONE",
          expiryFormatted = expString
        )
      }
    }
  }

  fun onCodeChanged(newCode: String) {
    _uiState.update { it.copy(inputCode = newCode, errorMessage = null) }
  }

  fun activate() {
    val code = _uiState.value.inputCode.trim()
    if (code.isBlank()) {
      _uiState.update { it.copy(errorMessage = "Koodii mirkaneessaa galchaa (Please enter activation code)") }
      return
    }

    viewModelScope.launch {
      _uiState.update { it.copy(isLoading = true, errorMessage = null, successMessage = null) }
      when (val result = securityManager.activateWithCode(code)) {
        is ActivationResult.Success -> {
          val expString = result.expiryTimestamp?.let { formatExpiry(it) }
          _uiState.update {
            it.copy(
              isLoading = false,
              isActivated = true,
              plan = result.plan,
              expiryFormatted = expString,
              successMessage = "Moobaayilli keessan milkaa'inaan bantameera! (App activated successfully!)",
              inputCode = ""
            )
          }
        }
        is ActivationResult.Error -> {
          _uiState.update {
            it.copy(
              isLoading = false,
              errorMessage = result.messageOm
            )
          }
        }
      }
    }
  }

  fun copyDeviceIdToClipboard() {
    val clipboard = getApplication<Application>().getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    val clip = ClipData.newPlainText("Device ID", _uiState.value.deviceId)
    clipboard.setPrimaryClip(clip)
    _uiState.update { it.copy(successMessage = "Device ID waraabameera! (Device ID copied)") }
  }

  fun clearMessages() {
    _uiState.update { it.copy(errorMessage = null, successMessage = null) }
  }

  private fun formatExpiry(timestampSec: Long): String {
    val date = Date(timestampSec * 1000L)
    val sdf = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault())
    return sdf.format(date)
  }
}
