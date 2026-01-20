# ===================================
# DrinkSomeWater Core Module ProGuard Rules
# ===================================

# ===== Kotlin =====
-keepattributes *Annotation*
-keepattributes Signature
-keep class kotlin.Metadata { *; }

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

# ===== Domain Models (CRITICAL) =====
# Keep all domain models for serialization
-keep class com.onceagain.drinksomewater.core.domain.model.** { *; }
-keepclassmembers class com.onceagain.drinksomewater.core.domain.model.** { *; }

# Keep data classes members
-keepclassmembers class com.onceagain.drinksomewater.core.data.** { *; }

# ===== DataStore =====
-keep class androidx.datastore.** { *; }
-keepclassmembers class * extends androidx.datastore.preferences.protobuf.GeneratedMessageLite {
    <fields>;
}

# ===== Kotlinx DateTime =====
-keep class kotlinx.datetime.** { *; }
-dontwarn kotlinx.datetime.**
