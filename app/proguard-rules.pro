# ==============================================================================
# ProGuard / R8 Rules for Lamif Kutaa 8 Prep (Release Build)
# ==============================================================================

# 1. Preserve line numbers and source file names for Crashlytics stack trace deobfuscation
-keepattributes SourceFile,LineNumberTable,*Annotation*,Signature,InnerClasses,EnclosingMethod
-renamesourcefileattribute SourceFile

# 2. Flutter Engine & Embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# 3. Isar Local Offline Database (Native JNI bindings & collections)
-keep class dev.isar.** { *; }
-keepclassmembers class dev.isar.** { *; }
-keep class * implements dev.isar.IsarLink { *; }
-keepclasseswithmembers class * {
    native <methods>;
}
-keepclassmembers class * {
    @dev.isar.annotation.* <fields>;
    @dev.isar.annotation.* <methods>;
}
-dontwarn dev.isar.**

# 4. Android WorkManager (Offline Background Sync)
-keep class androidx.work.** { *; }
-keep class dev.fluttercommunity.workmanager.** { *; }
-keepclassmembers class dev.fluttercommunity.workmanager.** { *; }
-dontwarn androidx.work.**

# 5. Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# 6. JSON serialization, Shared Preferences & Path Provider
-keepclassmembers class * {
    void set*(***);
    *** get*();
}
-keep class com.google.gson.** { *; }
-keep class com.squareup.moshi.** { *; }

# 7. Jetpack Compose & AndroidX Lifecycle
-keep class androidx.lifecycle.** { *; }
-keep class androidx.compose.** { *; }
-dontwarn androidx.compose.**
