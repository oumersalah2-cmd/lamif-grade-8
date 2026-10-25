package com.example.features.auth

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.local.AppDatabase
import com.example.data.local.entities.UserProfileEntity
import com.example.data.repository.ExamRepository
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class AuthUiState(
  val phoneNumber: String = "+2519",
  val otpCode: String = "",
  val isOtpSent: Boolean = false,
  val isLoading: Boolean = false,
  val errorMessage: String? = null,
  val successMessage: String? = null,
  val profile: UserProfileEntity = UserProfileEntity(),
  val isRegistered: Boolean = true
)

class AuthViewModel(application: Application) : AndroidViewModel(application) {
  private val repository = ExamRepository(AppDatabase.getDatabase(application))

  private val _state = MutableStateFlow(AuthUiState())
  val state: StateFlow<AuthUiState> = _state.asStateFlow()

  val userProfile = repository.getUserProfile().stateIn(
    scope = viewModelScope,
    started = SharingStarted.WhileSubscribed(5000),
    initialValue = null
  )

  fun onPhoneChanged(newPhone: String) {
    _state.value = _state.value.copy(phoneNumber = newPhone, errorMessage = null)
  }

  fun onOtpChanged(newOtp: String) {
    if (newOtp.length <= 6) {
      _state.value = _state.value.copy(otpCode = newOtp, errorMessage = null)
    }
  }

  fun requestOtp() {
    val phone = _state.value.phoneNumber.trim()
    if (phone.length < 9) {
      _state.value = _state.value.copy(errorMessage = "Lakkofsa bilbilaa sirrii galchaa (fkn: +251911234567)")
      return
    }

    viewModelScope.launch {
      _state.value = _state.value.copy(isLoading = true, errorMessage = null)
      delay(800) // Network OTP dispatch simulation
      _state.value = _state.value.copy(
        isLoading = false,
        isOtpSent = true,
        otpCode = "123456", // Pre-fill sample OTP for seamless testing
        successMessage = "Koodiin OTP bilbila $phone irratti ergameera (Koodii shaakalaa: 123456)"
      )
    }
  }

  fun verifyOtpAndLogin(fullName: String, zone: String, school: String) {
    val otp = _state.value.otpCode.trim()
    if (otp.length != 6) {
      _state.value = _state.value.copy(errorMessage = "Koodii lakkoofsa 6 galchaa")
      return
    }

    viewModelScope.launch {
      _state.value = _state.value.copy(isLoading = true, errorMessage = null)
      delay(800) // Backend JWT verification simulation

      val updatedProfile = UserProfileEntity(
        id = "current_student",
        fullName = if (fullName.isNotBlank()) fullName else "Barataa Kutaa 8ffaa",
        phoneNumber = _state.value.phoneNumber,
        zoneName = if (zone.isNotBlank()) zone else "Shawaa Bahaa",
        schoolName = if (school.isNotBlank()) school else "Mana Barumsaa Sad. 1ffaa",
        targetScore = 95,
        isVerified = true,
        streakDays = 4
      )

      repository.saveUserProfile(updatedProfile)
      _state.value = _state.value.copy(
        isLoading = false,
        isRegistered = true,
        successMessage = "Galmeen keessan milkaa'eera! Baga nagaan dhuftan!"
      )
    }
  }

  fun updateProfileDetails(name: String, zone: String, school: String, targetScore: Int) {
    viewModelScope.launch {
      val current = userProfile.value ?: UserProfileEntity()
      val updated = current.copy(
        fullName = name,
        zoneName = zone,
        schoolName = school,
        targetScore = targetScore
      )
      repository.saveUserProfile(updated)
      _state.value = _state.value.copy(successMessage = "Odeeffannoon profile keessanii fooyya'eera!")
    }
  }

  fun clearMessages() {
    _state.value = _state.value.copy(errorMessage = null, successMessage = null)
  }
}
