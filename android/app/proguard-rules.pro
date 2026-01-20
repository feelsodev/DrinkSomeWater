# ===================================
# DrinkSomeWater App ProGuard Rules
# ===================================

# ===== Kotlin =====
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Keep Kotlin Metadata
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**

# ===== Kotlinx Serialization =====
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

-keepclassmembers @kotlinx.serialization.Serializable class ** {
    *** Companion;
}
-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1>$Companion {
    kotlinx.serialization.KSerializer serializer(...);
}
-keepclasseswithmembers class ** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep domain models
-keep class com.onceagain.drinksomewater.core.domain.model.** { *; }
-keepclassmembers class com.onceagain.drinksomewater.core.domain.model.** { *; }

# ===== Hilt =====
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }
-keep class * extends dagger.hilt.android.internal.managers.ComponentSupplier { *; }
-keep class * extends dagger.hilt.android.internal.managers.ViewComponentManager$FragmentContextWrapper { *; }
-keepclassmembers class * {
    @dagger.hilt.android.AndroidEntryPoint *;
}

# ===== Jetpack Compose =====
-keep class androidx.compose.** { *; }
-dontwarn androidx.compose.**

# Keep Compose runtime
-keep class androidx.compose.runtime.** { *; }
-keepclassmembers class androidx.compose.runtime.** { *; }

# ===== Health Connect =====
-keep class androidx.health.connect.client.** { *; }
-keep class androidx.health.platform.client.** { *; }
-keepclassmembers class androidx.health.connect.client.** { *; }
-dontwarn androidx.health.**

# ===== Firebase =====
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Analytics
-keepclassmembers class * {
    @com.google.firebase.analytics.FirebaseAnalytics$Event *;
    @com.google.firebase.analytics.FirebaseAnalytics$Param *;
}

# ===== Google AdMob =====
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ===== WorkManager =====
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-keep class androidx.work.** { *; }

# ===== DataStore =====
-keep class androidx.datastore.** { *; }
-keepclassmembers class * extends androidx.datastore.preferences.protobuf.GeneratedMessageLite {
    <fields>;
}

# ===== Navigation Compose =====
-keep class androidx.navigation.** { *; }
-keepclassmembers class * {
    @androidx.navigation.NavDestination *;
}

# ===== Lifecycle =====
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * extends androidx.lifecycle.AndroidViewModel { *; }
-keepclassmembers class * extends androidx.lifecycle.ViewModel {
    <init>(...);
}

# ===== Enum classes =====
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ===== Parcelable =====
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# ===== R8 Full Mode =====
-allowaccessmodification
-repackageclasses ''

# ===== Debugging (remove in production) =====
# -keepattributes SourceFile,LineNumberTable
