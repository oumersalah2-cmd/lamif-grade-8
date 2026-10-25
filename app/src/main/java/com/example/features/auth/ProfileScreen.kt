package com.example.features.auth

import com.google.firebase.Firebase
import com.google.firebase.auth.auth
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.CloudDone
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
  viewModel: AuthViewModel,
  onNavigateBack: () -> Unit,
  modifier: Modifier = Modifier
) {
  val authState by viewModel.state.collectAsState()
  val profile by viewModel.userProfile.collectAsState()

  var nameInput by remember(profile?.fullName) { mutableStateOf(profile?.fullName ?: "Barataa Kutaa 8ffaa") }
  var schoolInput by remember(profile?.schoolName) { mutableStateOf(profile?.schoolName ?: "Mana Barumsaa Sad. 1ffaa") }
  var zoneInput by remember(profile?.zoneName) { mutableStateOf(profile?.zoneName ?: "Shawaa Bahaa") }
  var targetScoreInput by remember(profile?.targetScore) { mutableFloatStateOf(profile?.targetScore?.toFloat() ?: 90f) }

  var zoneExpanded by remember { mutableStateOf(false) }
  val oromiaZones = listOf(
    "Shawaa Bahaa",
    "Shawaa Dhihaa",
    "Shawaa Kaabaa",
    "Shawaa Kibba Lixaa",
    "Finfinnee Naannawaa",
    "Wallagga Bahaa",
    "Wallagga Dhihaa",
    "Qeellam Wallaggaa",
    "Horroo Guduruu Wallaggaa",
    "Jimma",
    "Iluu Abbaa Booraa",
    "Buno Baddallee",
    "Arsii",
    "Arsii Lixaa",
    "Baalee",
    "Baalee Bahaa",
    "Harargee Bahaa",
    "Harargee Dhihaa",
    "Gujii",
    "Gujii Lixaa",
    "Boorana"
  )

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = "Eenyummaa Barataa (Profile)",
            fontSize = 17.sp,
            fontWeight = FontWeight.Bold
          )
        },
        navigationIcon = {
          IconButton(onClick = onNavigateBack, modifier = Modifier.testTag("profile_back_btn")) {
            Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Deebi'i")
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(
          containerColor = MaterialTheme.colorScheme.surface
        )
      )
    },
    modifier = modifier
  ) { padding ->
    LazyColumn(
      modifier = Modifier
        .fillMaxSize()
        .padding(padding),
      contentPadding = PaddingValues(16.dp),
      verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      // 1. Profile Avatar Card
      item {
        Card(
          shape = RoundedCornerShape(20.dp),
          colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)),
          modifier = Modifier.fillMaxWidth()
        ) {
          Row(
            modifier = Modifier.padding(18.dp),
            verticalAlignment = Alignment.CenterVertically
          ) {
            Box(
              modifier = Modifier
                .size(60.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.primary),
              contentAlignment = Alignment.Center
            ) {
              Icon(
                imageVector = Icons.Default.School,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(32.dp)
              )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column {
              Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                  text = nameInput,
                  fontSize = 18.sp,
                  fontWeight = FontWeight.Bold,
                  color = MaterialTheme.colorScheme.onSurface
                )
                if (profile?.isVerified == true) {
                  Spacer(modifier = Modifier.width(6.dp))
                  Icon(
                    imageVector = Icons.Default.Verified,
                    contentDescription = "Mirkanaa'eera",
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(18.dp)
                  )
                }
              }

              Text(
                text = "$schoolInput • $zoneInput",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
              )

              Spacer(modifier = Modifier.height(4.dp))
              Text(
                text = "Qophii Qormaata Naannoo Kutaa 8ffaa",
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.primary
              )
            }
          }
        }
      }

      // 2. Google Sign-In & Firestore Cloud Sync Card (M3)
      item {
        val googleUser = Firebase.auth.currentUser
        val context = androidx.compose.ui.platform.LocalContext.current
        val coroutineScope = androidx.compose.runtime.rememberCoroutineScope()
        val credentialManager = androidx.credentials.CredentialManager.create(context)

        Card(
          shape = RoundedCornerShape(16.dp),
          colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
          elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Icon(
                imageVector = Icons.Default.CloudDone,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(22.dp)
              )
              Spacer(modifier = Modifier.width(8.dp))
              Text(
                text = "Eenyummaa Google & Duumessa (Firestore)",
                fontWeight = FontWeight.Bold,
                fontSize = 15.sp
              )
            }

            Spacer(modifier = Modifier.height(6.dp))

            if (googleUser != null) {
              Surface(
                shape = RoundedCornerShape(10.dp),
                color = Color(0xFFD4EDDA),
                modifier = Modifier.fillMaxWidth()
              ) {
                Row(
                  modifier = Modifier.padding(10.dp),
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = null,
                    tint = Color(0xFF155D27),
                    modifier = Modifier.size(20.dp)
                  )
                  Spacer(modifier = Modifier.width(8.dp))
                  Column {
                    Text(
                      text = "Google'n Seentaniittu (Signed In)",
                      fontWeight = FontWeight.Bold,
                      fontSize = 12.sp,
                      color = Color(0xFF155D27)
                    )
                    Text(
                      text = googleUser.email ?: googleUser.uid,
                      fontSize = 11.sp,
                      color = Color(0xFF155D27)
                    )
                  }
                }
              }

              Spacer(modifier = Modifier.height(10.dp))

              androidx.compose.material3.OutlinedButton(
                onClick = {
                  signOutGoogle(
                    context = context,
                    credentialManager = credentialManager,
                    onSignOutComplete = { },
                    scope = coroutineScope
                  )
                },
                shape = RoundedCornerShape(10.dp),
                modifier = Modifier.fillMaxWidth()
              ) {
                Text("Google Irraa Bahi (Sign Out)")
              }
            } else {
              Text(
                text = "Qabxii kee duumessa (Cloud Firestore) irratti eeguuf Google'n seeni.",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
              )
              Spacer(modifier = Modifier.height(12.dp))

              GoogleSignInButton(
                onAuthSuccess = { },
                onAuthError = { },
                modifier = Modifier.fillMaxWidth()
              )
            }
          }
        }
      }

      // 3. Phone OTP Authentication Card
      item {
        Card(
          shape = RoundedCornerShape(16.dp),
          colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
          elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Icon(
                imageVector = Icons.Default.Phone,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(20.dp)
              )
              Spacer(modifier = Modifier.width(8.dp))
              Text(
                text = "Galmee Bilbilaa (Phone Auth)",
                fontWeight = FontWeight.Bold,
                fontSize = 15.sp
              )
            }

            Spacer(modifier = Modifier.height(6.dp))
            Text(
              text = "Lakkofsa bilbilaan seenuun qabxii kee gara duumessaatti (cloud) qindeessi",
              fontSize = 12.sp,
              color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedTextField(
              value = authState.phoneNumber,
              onValueChange = { viewModel.onPhoneChanged(it) },
              label = { Text("Lakkofsa Bilbilaa (+251...)") },
              modifier = Modifier
                .fillMaxWidth()
                .testTag("phone_input"),
              singleLine = true,
              shape = RoundedCornerShape(12.dp)
            )

            if (!authState.isOtpSent) {
              Spacer(modifier = Modifier.height(10.dp))
              Button(
                onClick = { viewModel.requestOtp() },
                enabled = !authState.isLoading,
                modifier = Modifier
                  .fillMaxWidth()
                  .testTag("request_otp_btn"),
                shape = RoundedCornerShape(12.dp)
              ) {
                if (authState.isLoading) {
                  CircularProgressIndicator(modifier = Modifier.size(18.dp), color = Color.White)
                } else {
                  Text("Koodii OTP Ergi")
                }
              }
            } else {
              Spacer(modifier = Modifier.height(10.dp))
              OutlinedTextField(
                value = authState.otpCode,
                onValueChange = { viewModel.onOtpChanged(it) },
                label = { Text("Koodii OTP (Digit 6)") },
                modifier = Modifier
                  .fillMaxWidth()
                  .testTag("otp_input"),
                singleLine = true,
                shape = RoundedCornerShape(12.dp)
              )

              Spacer(modifier = Modifier.height(10.dp))
              Button(
                onClick = { viewModel.verifyOtpAndLogin(nameInput, zoneInput, schoolInput) },
                enabled = !authState.isLoading,
                modifier = Modifier
                  .fillMaxWidth()
                  .testTag("verify_otp_btn"),
                shape = RoundedCornerShape(12.dp)
              ) {
                if (authState.isLoading) {
                  CircularProgressIndicator(modifier = Modifier.size(18.dp), color = Color.White)
                } else {
                  Text("Mirkaneessi & Seeni (Verify)")
                }
              }
            }

            if (authState.successMessage != null) {
              Spacer(modifier = Modifier.height(8.dp))
              Text(
                text = authState.successMessage ?: "",
                color = Color(0xFF16A34A),
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium
              )
            }
            if (authState.errorMessage != null) {
              Spacer(modifier = Modifier.height(8.dp))
              Text(
                text = authState.errorMessage ?: "",
                color = Color(0xFFDC2626),
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium
              )
            }
          }
        }
      }

      // 3. Edit Profile Details
      item {
        Card(
          shape = RoundedCornerShape(16.dp),
          colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
          elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(modifier = Modifier.padding(16.dp)) {
            Text(
              text = "Odeeffannoo Barataa Fooyyessi",
              fontWeight = FontWeight.Bold,
              fontSize = 15.sp
            )

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedTextField(
              value = nameInput,
              onValueChange = { nameInput = it },
              label = { Text("Maqaa Guutuu") },
              modifier = Modifier.fillMaxWidth(),
              singleLine = true,
              shape = RoundedCornerShape(12.dp)
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Zone Selector
            ExposedDropdownMenuBox(
              expanded = zoneExpanded,
              onExpandedChange = { zoneExpanded = !zoneExpanded }
            ) {
              OutlinedTextField(
                value = zoneInput,
                onValueChange = {},
                readOnly = true,
                label = { Text("Godina / Bulchiinsa Magaalaa") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = zoneExpanded) },
                modifier = Modifier
                  .menuAnchor()
                  .fillMaxWidth(),
                shape = RoundedCornerShape(12.dp)
              )
              ExposedDropdownMenu(
                expanded = zoneExpanded,
                onDismissRequest = { zoneExpanded = false }
              ) {
                oromiaZones.forEach { zone ->
                  DropdownMenuItem(
                    text = { Text(zone) },
                    onClick = {
                      zoneInput = zone
                      zoneExpanded = false
                    }
                  )
                }
              }
            }

            Spacer(modifier = Modifier.height(10.dp))

            OutlinedTextField(
              value = schoolInput,
              onValueChange = { schoolInput = it },
              label = { Text("Mana Barumsaa") },
              modifier = Modifier.fillMaxWidth(),
              singleLine = true,
              shape = RoundedCornerShape(12.dp)
            )

            Spacer(modifier = Modifier.height(14.dp))

            // Target Score Slider
            Text(
              text = "Galma Qabxii Qormaata Naannoo: ${targetScoreInput.toInt()}%",
              fontSize = 13.sp,
              fontWeight = FontWeight.SemiBold
            )
            Slider(
              value = targetScoreInput,
              onValueChange = { targetScoreInput = it },
              valueRange = 50f..100f,
              steps = 10,
              modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(10.dp))

            Button(
              onClick = {
                viewModel.updateProfileDetails(
                  name = nameInput,
                  zone = zoneInput,
                  school = schoolInput,
                  targetScore = targetScoreInput.toInt()
                )
              },
              modifier = Modifier
                .fillMaxWidth()
                .testTag("save_profile_btn"),
              shape = RoundedCornerShape(12.dp)
            ) {
              Icon(imageVector = Icons.Default.Save, contentDescription = null, modifier = Modifier.size(16.dp))
              Spacer(modifier = Modifier.width(6.dp))
              Text("Odeeffannoo Olkaawi")
            }
          }
        }
      }

      // 4. Offline Storage Info
      item {
        Card(
          shape = RoundedCornerShape(16.dp),
          colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)),
          modifier = Modifier.fillMaxWidth()
        ) {
          Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
          ) {
            Icon(
              imageVector = Icons.Default.Storage,
              contentDescription = null,
              tint = MaterialTheme.colorScheme.primary,
              modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(12.dp))
            Column {
              Text(
                text = "Kuusaa Moobaayilaa (Room SQLite)",
                fontWeight = FontWeight.Bold,
                fontSize = 13.sp
              )
              Text(
                text = "Gaaffileen, bu'aan fi qabxiin kee intarneetii malee bilbila kee keessatti amansiisummaan kuufamu.",
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
              )
            }
          }
        }
      }
    }
  }
}
