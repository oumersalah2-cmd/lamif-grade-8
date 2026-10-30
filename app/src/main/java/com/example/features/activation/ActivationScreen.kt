package com.example.features.activation

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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LockOpen
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.VerifiedUser
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ActivationScreen(
  viewModel: ActivationViewModel,
  onNavigateBack: () -> Unit,
  modifier: Modifier = Modifier
) {
  val state by viewModel.uiState.collectAsState()

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Column {
            Text(
              text = "Mirkaneessa Moobaayilaa",
              fontWeight = FontWeight.Bold,
              fontSize = 17.sp
            )
            Text(
              text = "Offline Device Activation",
              fontSize = 11.sp,
              color = MaterialTheme.colorScheme.onSurfaceVariant
            )
          }
        },
        navigationIcon = {
          IconButton(onClick = onNavigateBack, modifier = Modifier.testTag("activation_back_btn")) {
            Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Deebi'i")
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
      )
    },
    modifier = modifier
  ) { padding ->
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(padding)
        .verticalScroll(rememberScrollState())
        .padding(20.dp),
      verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      // 1. Activation Status Banner
      Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
          containerColor = if (state.isActivated) Color(0xFFDCFCE7) else Color(0xFFFEF3C7)
        ),
        modifier = Modifier.fillMaxWidth()
      ) {
        Row(
          modifier = Modifier.padding(16.dp),
          verticalAlignment = Alignment.CenterVertically
        ) {
          Box(
            modifier = Modifier
              .size(44.dp)
              .clip(CircleShape)
              .background(if (state.isActivated) Color(0xFF16A34A) else Color(0xFFD97706)),
            contentAlignment = Alignment.Center
          ) {
            Icon(
              imageVector = if (state.isActivated) Icons.Default.LockOpen else Icons.Default.Lock,
              contentDescription = null,
              tint = Color.White,
              modifier = Modifier.size(22.dp)
            )
          }

          Spacer(modifier = Modifier.width(12.dp))

          Column {
            Text(
              text = if (state.isActivated) "Bantameera (Activated) 🌟" else "Qormaatawwan Cufamaniiru (Locked)",
              fontWeight = FontWeight.Bold,
              fontSize = 15.sp,
              color = if (state.isActivated) Color(0xFF15803D) else Color(0xFFB45309)
            )
            Text(
              text = if (state.isActivated) {
                if (state.expiryFormatted != null) "Hamma: ${state.expiryFormatted}tti tajaajila"
                else "Qormaata hunda yeroo daangaa hin qabneef fayyadamaa"
              } else {
                "Qormaatawwan ministirii hunda banachuuf koodii galchaa."
              },
              fontSize = 12.sp,
              color = if (state.isActivated) Color(0xFF166534) else Color(0xFF92400E)
            )
          }
        }
      }

      // 2. Student Device ID Card
      Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(modifier = Modifier.padding(16.dp)) {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
              imageVector = Icons.Default.PhoneAndroid,
              contentDescription = null,
              tint = MaterialTheme.colorScheme.primary,
              modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
              text = "Device ID Keessan",
              fontWeight = FontWeight.Bold,
              fontSize = 14.sp,
              color = MaterialTheme.colorScheme.onSurface
            )
          }

          Spacer(modifier = Modifier.height(6.dp))

          Text(
            text = "Lakkofsa kana barreessuun koodii baniinsaa argadhaa:",
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
          )

          Spacer(modifier = Modifier.height(10.dp))

          Surface(
            shape = RoundedCornerShape(10.dp),
            color = MaterialTheme.colorScheme.surfaceVariant,
            modifier = Modifier.fillMaxWidth()
          ) {
            Row(
              modifier = Modifier.padding(horizontal = 14.dp, vertical = 12.dp),
              horizontalArrangement = Arrangement.SpaceBetween,
              verticalAlignment = Alignment.CenterVertically
            ) {
              Text(
                text = state.deviceId,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                fontSize = 16.sp,
                color = MaterialTheme.colorScheme.primary
              )

              OutlinedButton(
                onClick = { viewModel.copyDeviceIdToClipboard() },
                modifier = Modifier.testTag("copy_device_id_btn"),
                shape = RoundedCornerShape(8.dp)
              ) {
                Icon(
                  imageVector = Icons.Default.ContentCopy,
                  contentDescription = "Waraabi",
                  modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text("Waraabi", fontSize = 11.sp)
              }
            }
          }
        }
      }

      // 3. Activation Code Input Section
      Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(modifier = Modifier.padding(16.dp)) {
          Text(
            text = "Koodii Baniinsaa (Activation Code)",
            fontWeight = FontWeight.Bold,
            fontSize = 14.sp
          )

          Spacer(modifier = Modifier.height(8.dp))

          OutlinedTextField(
            value = state.inputCode,
            onValueChange = { viewModel.onCodeChanged(it) },
            placeholder = { Text("LMF1.ey...", fontSize = 13.sp) },
            modifier = Modifier
              .fillMaxWidth()
              .testTag("activation_code_input"),
            maxLines = 4,
            shape = RoundedCornerShape(10.dp)
          )

          if (state.errorMessage != null) {
            Spacer(modifier = Modifier.height(8.dp))
            Text(
              text = state.errorMessage ?: "",
              color = Color(0xFFDC2626),
              fontSize = 12.sp,
              fontWeight = FontWeight.SemiBold
            )
          }

          if (state.successMessage != null) {
            Spacer(modifier = Modifier.height(8.dp))
            Text(
              text = state.successMessage ?: "",
              color = Color(0xFF16A34A),
              fontSize = 12.sp,
              fontWeight = FontWeight.SemiBold
            )
          }

          Spacer(modifier = Modifier.height(14.dp))

          Button(
            onClick = { viewModel.activate() },
            enabled = !state.isLoading,
            modifier = Modifier
              .fillMaxWidth()
              .testTag("submit_activation_btn"),
            shape = RoundedCornerShape(10.dp),
            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
          ) {
            if (state.isLoading) {
              CircularProgressIndicator(modifier = Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp)
            } else {
              Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Default.VerifiedUser, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Mirkaneessi (Activate Offline)", fontWeight = FontWeight.Bold, fontSize = 14.sp)
              }
            }
          }
        }
      }

      // 4. Privacy & Offline Verification Notice
      Surface(
        shape = RoundedCornerShape(12.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(modifier = Modifier.padding(12.dp)) {
          Text(
            text = "Eegumsa Nageenyaa (Offline Security):",
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.primary
          )
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "• Mirkaneessi kun intarneetii ykn sarvara hin barbaadu (100% Offline).\n• Device ID moobaayila kana qofaan daangaa malee tajaajila.\n• Daataan bilbila keessanii eenyummaa dhuunfaa hin qabatu.",
            fontSize = 11.sp,
            lineHeight = 16.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
          )
        }
      }
    }
  }
}
