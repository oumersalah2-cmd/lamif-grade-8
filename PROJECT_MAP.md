# PROJECT MAP: Lamif Grade 8 Offline Exam Prep

> **Purpose of this document:**  
> This file is a complete inventory of every folder and file in the project. For each item, it explains in plain English **what it does** and **what breaks if it is removed**. It also flags files that are too big, duplicate, unused, or confusing.

---

## 🚩 Quick Summary of Flags

| Flag Type | Files / Folders | Explanation |
| :--- | :--- | :--- |
| **Huge Files (>300 lines)** | `ExamScreen.kt` (693 lines)<br>`HomeScreen.kt` (611 lines)<br>`ProfileScreen.kt` (568 lines)<br>`ScheduleScreen.kt` (561 lines)<br>`StudyReminderCard.kt` (525 lines)<br>`ExamResultScreen.kt` (522 lines)<br>`PreloadedQuestions.kt` (355 lines) | These files have too many jobs at once. They must be split so each file has one clear, simple job. |
| **Duplicate Architectures** | Root Flutter (`lib/`, `pubspec.yaml`, `test/`) vs. Native Android (`app/`) | The repository contains two complete apps: a native Android Kotlin app (`app/`) and an earlier Flutter project (`lib/`). The active target is the native Android app. |
| **Unused Online Files** | `GoogleSignInHelper.kt`<br>`FirestoreSyncRepository.kt`<br>`FirestoreErrorHandler.kt`<br>`ExamSyncWorker.kt`<br>`SyncQueueEntity.kt`<br>`SyncDao.kt`<br>`firebase_applet_config.xml`<br>`backend/` (entire folder) | The app is strictly **offline-first**. These files attempt network connections, remote synchronization, or server APIs that are unneeded for an offline app. |
| **Confusing Names** | `com.example` (package name)<br>`SubjectCardItem` inside `HomeScreen.kt`<br>`MyApplicationTheme` | Generic placeholder names from templates that should be cleanly named after the app (`Lamif`). |

---

## 📁 1. Root Configuration & Build Files

* **`build.gradle.kts`**
  * *What it does:* The main build recipe file for the overall Android project. It loads plugins like Android Application and Kotlin.
  * *What breaks if removed:* The entire project cannot be built or compiled.
* **`settings.gradle.kts`**
  * *What it does:* Tells Gradle project settings, where to download libraries (Google, MavenCentral), and includes the `:app` module.
  * *What breaks if removed:* Gradle fails to find the app module and crashes on startup.
* **`gradle.properties`**
  * *What it does:* Configuration settings for the Gradle engine (memory limits, Kotlin code style).
  * *What breaks if removed:* Gradle uses slower default memory and flags warnings.
* **`gradle/libs.versions.toml`**
  * *What it does:* The centralized catalog listing every library version used by the Android app.
  * *What breaks if removed:* `build.gradle.kts` cannot look up library versions and fails to build.
* **`gradle/wrapper/gradle-wrapper.properties`**
  * *What it does:* Specifies the exact Gradle version to download and run.
  * *What breaks if removed:* The Gradle wrapper cannot run.
* **`key.properties.example`**
  * *What it does:* Template showing how to configure private release keystore passwords safely outside Git.
  * *What breaks if removed:* Developers must look up keystore properties manually.
* **`README.md`**
  * *What it does:* General project description and overview.
  * *What breaks if removed:* No documentation for new developers.
* **`TESTING.md`**
  * *What it does:* Quality assurance guide and test matrix for budget Ethiopian devices.
  * *What breaks if removed:* Testing procedures are undocumented.
* **`PROJECT_MAP.md`** *(This file)*
  * *What it does:* Complete architectural map and plain-English reference guide.
  * *What breaks if removed:* No file-by-file map for beginners.

---

## 📁 2. Native Android App (`app/`)

### A. Root of App Module
* **`app/build.gradle.kts`**
  * *What it does:* Defines app version, minimum Android version (API 24+), target Android version (API 35/36), signing configs, and libraries.
  * *What breaks if removed:* The Android app module cannot be built.
* **`app/proguard-rules.pro`**
  * *What it does:* Rules for code shrinking and minification (R8) so code is optimized and protected for release without breaking Room or models.
  * *What breaks if removed:* Release builds with minification enabled can break model serialization.
* **`app/src/main/AndroidManifest.xml`**
  * *What it does:* The manifest registered with the Android operating system declaring app name, icons, activities, broadcast receivers, and permissions.
  * *What breaks if removed:* Android cannot install or launch the application.

### B. Core Java/Kotlin Code (`app/src/main/java/com/example/`)

#### 1. Entry Point
* **`MainActivity.kt`**
  * *What it does:* The single Activity that launches the app, initializes edge-to-edge display, and sets up Compose navigation between Home, Exam, Result, Study Notes, Schedule, and Profile.
  * *What breaks if removed:* The app has no entry point and crashes when opened by the user.

#### 2. Features: Home (`features/home/`)
* **`HomeScreen.kt`** *(Huge File: 611 lines - Multi-job)*
  * *What it does:* Displays student greeting, study streak counter, quick action buttons (Mock Exam, Mistakes, Schedule, Study Notes), and the list of subjects.
  * *What breaks if removed:* The student has no home screen or way to pick subjects.
* **`HomeViewModel.kt`**
  * *What it does:* Loads user profile, past exam attempts, and computes average score for the dashboard.
  * *What breaks if removed:* `HomeScreen` receives no data and stays blank.

#### 3. Features: Exams (`features/exams/`)
* **`ExamScreen.kt`** *(Huge File: 693 lines - Multi-job)*
  * *What it does:* Displays the active question, 4 multiple-choice options, countdown timer, question palette navigator bottom sheet, next/previous buttons, and submit dialog.
  * *What breaks if removed:* The student cannot take any exam or test.
* **`ExamViewModel.kt`**
  * *What it does:* Manages exam state, question shuffling, answer selection, bookmarking, and scoring calculation.
  * *What breaks if removed:* `ExamScreen` cannot function; answers and timers cannot be updated.

#### 4. Features: Results (`features/results/`)
* **`ExamResultScreen.kt`** *(Huge File: 522 lines - Multi-job)*
  * *What it does:* Shows score percentage badge, passing status, time taken, correct vs. wrong breakdown, filter chips (All / Mistakes / Correct), and full question review with explanations.
  * *What breaks if removed:* Students cannot see their score or review what they got wrong.

#### 5. Features: Study Notes (`features/study/`)
* **`StudyNotesScreen.kt`**
  * *What it does:* Shows key formulas, grammar rules, and scientific facts organized by subject with filter chips.
  * *What breaks if removed:* Quick-revision reference notes cannot be viewed.

#### 6. Features: Schedule & Daily Reminders (`features/schedule/`)
* **`ScheduleScreen.kt`** *(Huge File: 561 lines - Multi-job)*
  * *What it does:* Daily timetable for studying, daily progress indicator, day-of-week picker, and button to add sessions.
  * *What breaks if removed:* Students cannot view or manage their daily study plan.
* **`ScheduleViewModel.kt`**
  * *What it does:* Reads/writes daily sessions in the Room database and communicates with the reminder scheduler.
  * *What breaks if removed:* The schedule screen cannot load or save study sessions.
* **`components/StudyReminderCard.kt`** *(Huge File: 525 lines - Multi-job)*
  * *What it does:* UI card to set reminder time (e.g. 5:00 PM), toggle notifications on/off, test reminder, and check Android notification permissions.
  * *What breaks if removed:* Notification settings cannot be changed.
* **`notifications/StudyReminderScheduler.kt`**
  * *What it does:* Sets alarms using Android's `AlarmManager` and `WorkManager` so reminders ring even when the app is closed.
  * *What breaks if removed:* Study alarms will never fire in the background.
* **`notifications/StudyNotificationHelper.kt`**
  * *What it does:* Creates notification channels and builds the visible status bar notification in Afaan Oromoo.
  * *What breaks if removed:* Notifications cannot appear in the Android notification bar.
* **`notifications/StudyReminderReceiver.kt`**
  * *What it does:* Listens for alarm triggers and device reboot (`BOOT_COMPLETED`) to reschedule alarms automatically.
  * *What breaks if removed:* Alarms stop working after the phone restarts.
* **`notifications/StudyReminderWorker.kt`**
  * *What it does:* WorkManager background task that serves as a fallback reminder on aggressive battery-saving phones.
  * *What breaks if removed:* Devices in deep sleep may drop the reminder.

#### 7. Features: Auth & Profile (`features/auth/`)
* **`ProfileScreen.kt`** *(Huge File: 568 lines - Multi-job)*
  * *What it does:* Displays student name, zone, school, target score, and theme settings.
  * *What breaks if removed:* Profile editing cannot be opened.
* **`AuthViewModel.kt`**
  * *What it does:* Manages profile saving. *(Contains legacy OTP network simulation).*
  * *What breaks if removed:* Profile information cannot be saved.
* **`GoogleSignInHelper.kt`** *(Unused / Dangerous Flag)*
  * *What it does:* Attempts online Google Sign-In using Firebase credentials.
  * *What breaks if removed:* Nothing breaks in offline mode. If invoked currently, it crashes due to missing web client ID.

#### 8. Data Layer: Database & Entities (`data/local/`)
* **`AppDatabase.kt`**
  * *What it does:* The central Room SQLite database class. Manages tables, migrations, and seeds preloaded questions.
  * *What breaks if removed:* All local persistence fails.
* **`entities/QuestionEntity.kt`**
  * *What it does:* Defines the table schema for exam questions (id, subject, topic, options, correct index, explanation, year).
  * *What breaks if removed:* Room cannot store or query questions.
* **`entities/ExamAttemptEntity.kt`**
  * *What it does:* Stores past completed exam attempts, scores, time taken, and student answers.
  * *What breaks if removed:* Student exam history and scores cannot be saved.
* **`entities/BookmarkEntity.kt`**
  * *What it does:* Stores saved/bookmarked question IDs.
  * *What breaks if removed:* Bookmarks cannot be remembered.
* **`entities/UserProfileEntity.kt`**
  * *What it does:* Stores student name, school, zone, streak days, and score target.
  * *What breaks if removed:* User settings revert to defaults on every restart.
* **`entities/StudySessionEntity.kt`**
  * *What it does:* Stores daily schedule items (day of week, time, duration, completed status).
  * *What breaks if removed:* Schedule items cannot be persisted.
* **`entities/SyncQueueEntity.kt`** *(Unused Online Flag)*
  * *What it does:* Stores pending network sync jobs for a cloud backend.
  * *What breaks if removed:* Only cloud sync is affected; offline functionality is unaffected.

#### 9. Data Layer: DAOs (`data/local/dao/`)
* **`QuestionDao.kt`**: SQL queries to read questions by subject, ID, or count.
* **`ExamDao.kt`**: SQL queries to read/write exam attempts.
* **`BookmarkDao.kt`**: SQL queries to insert, remove, and check bookmarks.
* **`UserDao.kt`**: SQL queries to load and update student profile.
* **`StudySessionDao.kt`**: SQL queries to read, insert, toggle, and delete timetable sessions.
* **`SyncDao.kt`** *(Unused Online Flag)*: SQL queries for sync queue.

#### 10. Data Layer: Repositories & Models (`data/`)
* **`model/Subject.kt`**
  * *What it does:* Enum of the 6 Grade 8 subjects (Afaan Oromoo, Herrega, Saayinsii Waliigalaa, Saayinsii Hawaasaa, Lammummaa, English) with icons, colors, and descriptions.
  * *What breaks if removed:* The entire subject navigation system breaks.
* **`repository/ExamRepository.kt`**
  * *What it does:* Connects ViewModels to DAOs for questions, attempts, bookmarks, and profile.
  * *What breaks if removed:* ViewModels cannot access the database.
* **`repository/ScheduleRepository.kt`**
  * *What it does:* Connects ScheduleViewModel to `StudySessionDao`.
  * *What breaks if removed:* Schedule screen cannot load sessions.
* **`preloaded/PreloadedQuestions.kt`** *(Huge File: 355 lines)*
  * *What it does:* Hardcoded list of past exam questions across all subjects used to seed the database.
  * *What breaks if removed:* The database initializes empty with 0 questions.
* **`preloaded/PreloadedStudyNotes.kt`**
  * *What it does:* Hardcoded list of key formulas and summary notes used to populate Study Notes.
  * *What breaks if removed:* Study notes screen appears completely empty.
* **`sync/ExamSyncWorker.kt`** *(Unused Online Flag)*
  * *What it does:* Background worker attempting network sync with a remote API.
  * *What breaks if removed:* Nothing breaks offline.
* **`firestore/FirestoreSyncRepository.kt` & `FirestoreErrorHandler.kt`** *(Unused Online Flag)*
  * *What it does:* Legacy code for cloud Firestore database sync.
  * *What breaks if removed:* Nothing breaks offline.

#### 11. UI Theme & Styling (`ui/theme/`)
* **`Theme.kt`**
  * *What it does:* Sets up MaterialTheme with high-contrast color palettes for students.
  * *What breaks if removed:* Material 3 components have no theme styling.
* **`Color.kt`**
  * *What it does:* Hex color definitions (Oromia Green, Gold, Red, Dark Surface).
  * *What breaks if removed:* Theme colors fail to compile.
* **`Type.kt`**
  * *What it does:* Typography styling (font sizes, line heights, weights).
  * *What breaks if removed:* Text styles fail to compile.
* **`AppThemeManager.kt`**
  * *What it does:* Manages Light, Dark, and System theme preferences in SharedPreferences.
  * *What breaks if removed:* Theme switching does not persist.
* **`ThemeSettingCard.kt`**
  * *What it does:* UI widget card allowing students to select Light, Dark, or System mode.
  * *What breaks if removed:* Profile screen loses theme settings widget.

---

## 📁 3. Android Resources (`app/src/main/res/`)

* **`values/strings.xml`**
  * *What it does:* Declares string resources. Currently only has `app_name`.
  * *What breaks if removed:* App title cannot be resolved.
* **`values/colors.xml`**: XML color definitions.
* **`values/themes.xml`**: Android system splash and base activity theme.
* **`values/firebase_applet_config.xml`**: *(Unused Online Flag)* Legacy Firebase configuration.
* **`xml/backup_rules.xml` & `xml/data_extraction_rules.xml`**: Configures Android 12+ backup behavior.
* **`drawable/` & `mipmap-*/`**: App launcher icons and adaptive icons for various screen densities.

---

## 📁 4. Legacy Flutter Files (`lib/`, `test/`, `pubspec.yaml`) *(Duplicate Architecture Flag)*

*These files represent a parallel Flutter implementation of the app.*
* **`pubspec.yaml` & `pubspec.lock`**: Flutter dependencies and configuration.
* **`lib/`**: Flutter UI, Riverpod state, and Isar database code.
* **`test/`**: Flutter Dart unit tests.
* **`linux/`**: Flutter Linux desktop runner files.

---

## 📁 5. Backend Server Files (`backend/`) *(Unused Online Flag)*

* **`backend/src/`**: Node.js Express server code with authentication, SMS, and database routes.
* **`backend/prisma/`**: PostgreSQL database schema.
* **`backend/Dockerfile` & `docker-compose.prod.yml`**: Server hosting scripts.
* *Note:* Completely detached from the offline mobile application.
